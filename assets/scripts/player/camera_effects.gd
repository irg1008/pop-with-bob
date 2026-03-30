class_name CameraEffects extends Camera3D


@export_category("References")
@export var player_controller: PlayerController

@export_category("Effects")
@export var enable_tilt: bool = true
@export var enable_fall_kick: bool = true
@export var enable_damage_kick: bool = true
@export var enable_weapon_kick: bool = true
@export var enable_screen_shake: bool = true
@export var enable_headbob: bool = true

@export_category("Kick & Recoil Settings")
@export_group("Run Tilt")
@export var run_pitch: float = 0.1 # Degrees
@export var run_roll: float = 0.25 # Degrees
@export var max_pitch: float = 1.0 # Degrees
@export var max_roll: float = 2.5 # Degrees
@export_group("Camera Kick")
@export_subgroup("Fall Kick")
@export var fall_kick_pitch: float = 2.0 # Degrees
@export var fall_kick_time: float = 0.3
@export_subgroup("Damage Kick")
@export var damage_kick_roll: float = 5.0 # Degrees
@export var damage_kick_pitch: float = 5.0 # Degrees
@export var damage_kick_time: float = 0.3
@export_subgroup("Weapon Kick")
@export var weapon_decay: float = 0.5
@export_subgroup("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch: float = 0.05 # Degrees
@export_range(0.0, 0.1, 0.001) var bob_roll: float = 0.05 # Degrees
@export_range(0.0, 0.04, 0.001) var bob_up: float = 0.02
@export_range(0.0, 2.0, 0.1) var bob_frequency: float = 0.25
@export_range(0.0, 1.0, 0.1) var bob_amplitude: float = 0.25


const MIN_SCREEN_SHAKE: float = 0.05
const MAX_SCREEN_SHAKE: float = 0.5


var _fall_kick_timer: float = 0.0

var _damage_kick_timer: float = 0.0
var _damage_kick_angles: Vector3 = Vector3.ZERO

var _weapon_kick_angles: Vector3 = Vector3.ZERO

var _screen_shake_tween: Tween

var _bob_step_timer: float = 0.0


func _process(delta: float) -> void:
	calculate_view_offset(delta)


func calculate_tilt(direction: Vector3, velocity: Vector3, deg: float, max_deg: float) -> float:
	var dot: float = velocity.dot(direction)

	var max_rad: float = deg_to_rad(max_deg)
	var tilt: float = clampf(dot * deg_to_rad(deg), -max_rad, max_rad)

	return tilt


func calculate_bob_amount(delta: float) -> float:
	# We calculate speed without vertical velocity to avoid headbob when falling or jumping
	var velocity: Vector3 = player_controller.velocity
	var speed: float = Vector2(velocity.x, velocity.z).length()

	if speed > 0.1 and player_controller.is_on_floor():
		# Cycle faster with higher speed
		_bob_step_timer += delta * bob_frequency * speed
		_bob_step_timer = fmod(_bob_step_timer, 1)
	else:
		_bob_step_timer = 0.0

	var bob_sin: float = sin(_bob_step_timer * TAU) * bob_amplitude # Smoother sine wave

	# More headbob with higher speed
	return bob_sin * speed


func calculate_view_offset(delta: float) -> void:
	if not player_controller:
		return

	_fall_kick_timer -= delta
	_damage_kick_timer -= delta

	var velocity: Vector3 = player_controller.velocity

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
		var fall_kick_amount: float = fall_kick_ratio * deg_to_rad(fall_kick_pitch)
		angles.x -= fall_kick_amount
		offset.y -= fall_kick_amount

	# Damage Kick
	if enable_damage_kick:
		var damage_kick_ratio: float = max(0.0, _damage_kick_timer / damage_kick_time)
		damage_kick_ratio = ease(damage_kick_ratio, -1) # Ease in-out
		var damage_kick_amount: Vector3 = damage_kick_ratio * _damage_kick_angles
		angles += damage_kick_amount

	# Weapon Kick
	if enable_weapon_kick:
		_weapon_kick_angles = _weapon_kick_angles.move_toward(Vector3.ZERO, weapon_decay * delta)
		angles += _weapon_kick_angles

	# Headbob
	if enable_headbob:
		var bob_amount: float = calculate_bob_amount(delta)

		# Apply headbob
		var pitch_delta: float = deg_to_rad(bob_pitch) * bob_amount
		var roll_delta: float = deg_to_rad(bob_roll) * bob_amount
		var bob_height: float = bob_up * bob_amount

		angles.x -= pitch_delta
		angles.z -= roll_delta
		offset.y += bob_height


	position = offset
	rotation = angles


func add_fall_kick() -> void:
	_fall_kick_timer = fall_kick_time


func add_damage_kick(source: Vector3) -> void:
	_damage_kick_timer = damage_kick_time

	var direction: Vector3 = global_position.direction_to(source)
	var forward: Vector3 = global_transform.basis.z
	var side: Vector3 = global_transform.basis.x

	var pitch: float = deg_to_rad(damage_kick_pitch) * direction.dot(forward)
	var roll: float = deg_to_rad(damage_kick_roll) * direction.dot(side)

	_damage_kick_angles = Vector3(pitch, 0.0, roll)


func add_weapon_kick(pitch: float, yaw: float, roll: float) -> void:
	_weapon_kick_angles.x += deg_to_rad(pitch)
	_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))


func update_screen_shake(progress: float, amount: float) -> void:
	amount = remap(amount, 0.0, 1.0, MIN_SCREEN_SHAKE, MAX_SCREEN_SHAKE)

	# We use (1 - progress) to invert tween and have strong shake at the start
	var current_shake_amount: float = amount * (1.0 - progress)
	h_offset = randf_range(-current_shake_amount, current_shake_amount)
	v_offset = randf_range(-current_shake_amount, current_shake_amount)


func add_screen_shake(amount: float, seconds: float) -> void:
	if _screen_shake_tween:
		_screen_shake_tween.kill()

	var tween_method: Callable = update_screen_shake.bind(amount)

	_screen_shake_tween = create_tween()
	_screen_shake_tween.tween_method(tween_method, 0.0, 1.0, seconds).set_ease(Tween.EASE_OUT)
