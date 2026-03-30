class_name CameraController extends Node3D


enum CameraDirection {
	UP = 1,
	DOWN = -1
}


@export_category("References")
@export var player_controller: PlayerController
@export var mouse_capture_component: MouseCaptureComponent

@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90, -60) var tilt_lower_limit: int = -90
@export_range(60, 90) var tilt_upper_limit: int = 90
@export_group("Camera Vertical Movement")
@export var crouch_offset: float = 0.0
@export var crouch_speed: float = 3.0
@export_group("Step Smoothing")
@export var step_speed: float = 8.0


const DEFAULT_HEIGHT: float = 0.5


var _rotation: Vector3

var _target_height: float
var _step_smoothing: bool = false

var offset_height: float = 0.0


func _ready() -> void:
	_rotation = player_controller.rotation
	offset_height = DEFAULT_HEIGHT
	

func _process(delta: float) -> void:
	update_camera_rotation(mouse_capture_component.mouse_input)

	if _step_smoothing:
		_target_height = lerp(_target_height, 0.0, step_speed * delta)

		if (abs(_target_height) < 0.01):
			_target_height = 0.0
			_step_smoothing = false

	position.y = offset_height + _target_height


func update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))

	var _player_rotation: Vector3 = Vector3(0.0, _rotation.y, 0.0) # Player rotation only on the Y axis
	var _camera_rotation: Vector3 = Vector3(_rotation.x, 0.0, 0.0) # Camera rotation only on the X axis

	transform.basis = Basis.from_euler(_camera_rotation)
	player_controller.update_rotation(_player_rotation)

	_rotation.z = 0.0


func update_camera_height(delta: float, direction: CameraDirection) -> void:
	if offset_height >= crouch_offset and offset_height <= DEFAULT_HEIGHT:
		offset_height = clampf(offset_height + (crouch_speed * direction) * delta, crouch_offset, DEFAULT_HEIGHT)


func smooth_step(height_change: float) -> void:
	_target_height -= height_change
	_step_smoothing = true
