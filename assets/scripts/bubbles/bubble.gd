class_name Bubble extends Node3D


const POP_BASE_VOLUME_DB: float = -6.0
const POP_VOLUME_VARIATION_DB: float = 1.0
const POP_PITCH_MIN: float = 0.96
const POP_PITCH_MAX: float = 1.04


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

@export_category("Bubble Properties")
@export var wobble_strength: float = 0.5
@export var wobble_rotation_strength: float = 0.035


var max_lifetime: float
var time_alive: float = 0.0

static var _last_pop_sound_index: int = -1


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

		var yaw_torque: float = randf_range(-1.0, 1.0) * wobble_rotation_strength
		rigid_body.apply_torque(Vector3.UP * yaw_torque)


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
	if animation_player and animation_player.has_animation("inflate"):
		animation_player.play("inflate")


func pop() -> void:
	pop_effect.global_position = rigid_body.global_position
	pop_effect.restart()

	popped.emit()
	rigid_body.queue_free()
	play_random_audio(pop_sounds)


func play_random_audio(audios: Array[AudioStream]) -> void:
	if not audio_player or audios.is_empty():
		return

	audio_player.global_position = rigid_body.global_position

	var random_index: int = _pick_pop_sound_index(audios)
	audio_player.stream = audios[random_index]
	audio_player.pitch_scale = randf_range(POP_PITCH_MIN, POP_PITCH_MAX)
	audio_player.volume_db = POP_BASE_VOLUME_DB + randf_range(-POP_VOLUME_VARIATION_DB, POP_VOLUME_VARIATION_DB)
	audio_player.play()


func _pick_pop_sound_index(audios: Array[AudioStream]) -> int:
	if audios.size() == 1:
		_last_pop_sound_index = 0
		return 0

	var random_index: int = randi_range(0, audios.size() - 1)
	if random_index == _last_pop_sound_index:
		random_index = (random_index + 1 + randi_range(0, audios.size() - 2)) % audios.size()

	_last_pop_sound_index = random_index
	return random_index


func _on_pop_effect_finished() -> void:
	queue_free()
