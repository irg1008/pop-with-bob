class_name CameraEffects extends Camera3D

@export var debug: bool = false

@export_category("References")
@export var player: PlayerController

@export_category("Effects")
@export var enable_tilt: bool = true
@export var enable_fall_kick: bool = true

@export_category("Kick & Recoil Settings")
@export_group("Run Tilt")
@export var run_pitch: float = 0.1 # Degrees
@export var run_roll: float = 0.25 # Degrees
@export var max_pitch: float = 1.0 # Degrees
@export var max_roll: float = 2.5 # Degrees
@export_group("Camera Kick")
@export_subgroup("Fall Kick")
@export var fall_kick_amount: float = 2.0 # Degrees
@export var fall_kick_time: float = 0.3

var _fall_kick_timer: float = 0.0


func _process(delta: float) -> void:
	calculate_view_offset(delta)


func calculate_tilt(direction: Vector3, velocity: Vector3, deg: float, max_deg: float) -> float:
	var dot: float = velocity.dot(direction)

	var max_rad: float = deg_to_rad(max_deg)
	var tilt: float = clampf(dot * deg_to_rad(deg), -max_rad, max_rad)

	return tilt


func calculate_view_offset(delta: float) -> void:
	if not player:
		return

	_fall_kick_timer -= delta

	var velocity: Vector3 = player.velocity

	var angles: Vector3 = Vector3.ZERO
	var offset: Vector3 = Vector3.ZERO

	# Camera Tilt
	if enable_tilt:
		var forward: Vector3 = global_transform.basis.z
		var side: Vector3 = global_transform.basis.x
		angles.x += calculate_tilt(forward, velocity, run_pitch, max_pitch)
		angles.z -= calculate_tilt(side, velocity, run_roll, max_roll)

	# Fall Kick
	if enable_fall_kick:
		var fall_kick_ratio: float = max(0.0, _fall_kick_timer / fall_kick_time)
		var fall_kick_delta: float = fall_kick_ratio * deg_to_rad(fall_kick_amount)
		angles.x -= fall_kick_delta
		offset.y -= fall_kick_delta

	position = offset
	rotation = angles


func add_fall_kick() -> void:
	_fall_kick_timer = fall_kick_time