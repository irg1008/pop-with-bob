class_name PlayerController extends StairsCharacter3D


@export_category("References")
@export var camera: CameraController
@export var camera_effects: CameraEffects
@export var state_chart: StateChart
@export var standing_collision: CollisionShape3D
@export var crouching_collision: CollisionShape3D
@export var crouch_check: ShapeCast3D
@export var interaction_raycast: RayCast3D
@export var weapon_controller: WeaponController

@export_category("Movement Settings")
@export_group("Easing")
@export var acceleration: float = 0.2
@export var deceleration: float = 0.5
@export_group("Speed")
@export var base_speed: float = 4.0
@export var sprint_speed: float = 2.0
@export var crouch_speed: float = -2.0

@export_category("Jump Settings")
@export var jump_velocity: float = 5.0
@export var fall_velocity_threhold: float = -5.0


const MIN_STEP_HEIGHT: float = 0.01
const STEP_HEIGHT_MARGIN: float = 0.001


var _input_dir: Vector2 = Vector2.ZERO
var _movement_velocity: Vector3 = Vector3.ZERO

var _speed: float = 0.0
var _sprint_modifier: float = 0.0
var _crouch_modifier: float = 0.0

var _current_fall_speed: float = 0.0

var previous_velocity: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
	previous_velocity = velocity

	if not is_on_floor():
		velocity += get_gravity() * delta

	var speed_modifier: float = _sprint_modifier + _crouch_modifier
	_speed = base_speed + speed_modifier

	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()

	var current_velocity: Vector2 = Vector2(_movement_velocity.x, _movement_velocity.z)
	if direction:
		current_velocity = lerp(current_velocity, Vector2(direction.x, direction.z) * _speed, acceleration)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)

	_movement_velocity = Vector3(current_velocity.x, velocity.y, current_velocity.y)
	velocity = _movement_velocity

	smooth_move_and_start_step()


func smooth_move_and_start_step() -> void:
	var previous_height: float = position.y

	move_and_stair_step()

	var height_delta: float = position.y - previous_height
	var rounded_height_delta: float = snapped(absf(height_delta), STEP_HEIGHT_MARGIN)

	var step_height: float = step_height_up if height_delta > 0 else step_height_down
	var is_step: bool = rounded_height_delta > MIN_STEP_HEIGHT and rounded_height_delta <= step_height

	if is_on_floor() and is_step:
		camera.smooth_step(height_delta)


func get_input_direction() -> Vector2:
	return _input_dir


func update_rotation(rotation_input: Vector3) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)


func sprint() -> void:
	_sprint_modifier = sprint_speed


func walk() -> void:
	_sprint_modifier = 0.0


func crouch() -> void:
	_crouch_modifier = crouch_speed
	standing_collision.disabled = true
	crouching_collision.disabled = false
	collider = crouching_collision.get_path()


func stand() -> void:
	_crouch_modifier = 0.0
	standing_collision.disabled = false
	crouching_collision.disabled = true
	collider = standing_collision.get_path()


func jump() -> void:
	velocity.y += jump_velocity


func update_fall_speed() -> void:
	_current_fall_speed = velocity.y


func check_fall_speed() -> bool:
	var is_falling: bool = _current_fall_speed < fall_velocity_threhold
	_current_fall_speed = 0.0
	return is_falling
