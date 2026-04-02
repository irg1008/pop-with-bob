class_name Bubble extends Node3D


signal popped()
signal inflated()


@export var debug: bool = false

@export_category("References")
@export var animation_player: AnimationPlayer
@export var rigid_body: RigidBody3D
@export var bubble_pivot: Node3D
@export var audio_player: AudioStreamPlayer3D
@export var pop_effect: GPUParticles3D
@export var pop_sounds: Array[AudioStream] = []
@export var inflate_sounds: Array[AudioStream] = []

@export_category("Bubble Properties")
@export var wobble_strength: float = 0.5


var max_lifetime: float
var time_alive: float = 0.0


func _ready() -> void:
	bubble_pivot.scale = Vector3.ZERO

	rigid_body.freeze = true
	rigid_body.sleeping = true
	rigid_body.contact_monitor = false

	inflate()
	animation_player.animation_finished.connect(_on_inflate_animation_finished)

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


func _on_inflate_animation_finished(_animation_name: String) -> void:
	if not rigid_body:
		return

	inflated.emit()

	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 1
	rigid_body.top_level = true

	if not debug:
		rigid_body.sleeping = false
		rigid_body.freeze = false

	rigid_body.apply_central_impulse(Vector3.FORWARD * 0.01)


func _on_body_entered(_body: Node) -> void:
	pop()


func _on_health_component_died() -> void:
	pop()


func inflate() -> void:
	play_random_audio(inflate_sounds)
	if animation_player and animation_player.has_animation("inflate"):
		animation_player.play("inflate")


func pop() -> void:
	pop_effect.global_position = rigid_body.global_position
	pop_effect.restart()

	popped.emit()
	rigid_body.queue_free()
	play_random_audio(pop_sounds)


func play_random_audio(audios: Array[AudioStream]) -> void:
	if audio_player and audios.size() > 0:
		var random_index: int = randi_range(0, audios.size() - 1)
		audio_player.stream = audios[random_index]
		audio_player.play()


func _on_pop_effect_finished() -> void:
	queue_free()
