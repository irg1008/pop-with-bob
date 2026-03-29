class_name MouseCaptureComponent extends Node


@export var debug: bool = false

@export_category("Mouse Capture Settings")
@export var current_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity: float = 0.005

var _capture_mouse: bool
var _mouse_input: Vector2


func _ready() -> void:
	Input.set_mouse_mode(current_mouse_mode)


func _process(_delta: float) -> void:
	_mouse_input = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	_capture_mouse = event is InputEventMouseMotion and Input.get_mouse_mode() == current_mouse_mode

	if _capture_mouse:
		var mouse_event: InputEventMouseMotion = event
		_mouse_input.x -= mouse_event.screen_relative.x * mouse_sensitivity
		_mouse_input.y -= mouse_event.screen_relative.y * mouse_sensitivity

	if debug:
		print(_mouse_input)
