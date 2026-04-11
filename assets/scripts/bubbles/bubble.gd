class_name Bubble extends Node3D


signal popped()
signal inflated()


@export var debug: bool = false

@export_category("References")
@export var rigid_body: RigidBody3D
@export var bubble_pivot: Node3D
@export var audio_player: AudioStreamPlayer3D
@export var pop_effect: GPUParticles3D
@export var pop_sounds: Array[AudioStream] = []

@export_category("Bubble Properties")
@export var wobble_strength: float = 0.5
@export var wobble_rotation_strength: float = 0.035
@export var inflate_speed: float = 1.0
@export var max_scale: float = 1.0
@export var max_lifetime: float = 0.0

@export_category("Collision")
@export var collision_groups: Array[String] = [CharacterBubbleEmitter.CHARACTER_GROUP]


const MIN_PHYSICS_SAFE_SCALE: float = 0.001


var time_alive: float = 0.0


func _ready() -> void:
	bubble_pivot.scale = Vector3.ONE * MIN_PHYSICS_SAFE_SCALE

	disable_rigid_body()
	await inflate()

	rigid_body.body_entered.connect(_on_body_entered)
	pop_effect.finished.connect(_on_pop_effect_finished)


func _physics_process(delta: float) -> void:
	if not rigid_body:
		return

	time_alive += delta
	if max_lifetime > 0.0 and time_alive >= max_lifetime:
		pop()
		return

	if not rigid_body.freeze:
		var random_direction: Vector3 = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		rigid_body.apply_central_force(random_direction * wobble_strength)

		var yaw_torque: float = randf_range(-1.0, 1.0) * wobble_rotation_strength
		rigid_body.apply_torque(Vector3.UP * yaw_torque)


func release_bubble() -> void:
	if not rigid_body:
		return

	enable_rigid_body()
	rigid_body.apply_central_impulse(Vector3.FORWARD * 0.01)


func _on_body_entered(body: Node) -> void:
	for group: String in collision_groups:
		if body.is_in_group(group):
			pop()
			return


func _on_health_component_died() -> void:
	pop()


func inflate() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(bubble_pivot, "scale", Vector3.ONE * 0.2, 0.3 * inflate_speed).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble_pivot, "scale", Vector3.ONE * 0.2, 0.2 * inflate_speed)
	tween.tween_property(bubble_pivot, "scale", Vector3.ONE * max_scale, 0.5 * inflate_speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished

	inflated.emit()
	release_bubble()


func pop() -> void:
	pop_effect.global_position = rigid_body.global_position
	pop_effect.restart()

	popped.emit()
	rigid_body.visible = false
	play_random_audio(pop_sounds)


func play_random_audio(audios: Array[AudioStream]) -> void:
	if audio_player and audios.size() > 0:
		audio_player.global_position = rigid_body.global_position
		var random_index: int = randi_range(0, audios.size() - 1)
		audio_player.stream = audios[random_index]
		audio_player.play()


func _on_pop_effect_finished() -> void:
	queue_free()


func disable_rigid_body() -> void:
	rigid_body.freeze = true
	rigid_body.sleeping = true
	rigid_body.contact_monitor = false


func enable_rigid_body() -> void:
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 1
	rigid_body.top_level = true

	if not debug:
		rigid_body.sleeping = false
		rigid_body.freeze = false