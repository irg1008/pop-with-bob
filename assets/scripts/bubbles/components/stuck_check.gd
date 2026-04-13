class_name StuckCheckComponent extends Node


signal stuck()


@export_category("References")
@export var parent: Node3D


var is_stuck: bool = false
var _stuck_check_timer: Timer
var _stuck_check_position: Vector3


func _ready() -> void:
	create_stuck_check()


func create_stuck_check() -> void:
	_stuck_check_timer = Timer.new()
	add_child(_stuck_check_timer)
	_stuck_check_timer.wait_time = 1.0
	_stuck_check_timer.start()
	_stuck_check_timer.timeout.connect(_on_stuck_check_timeout)


func _on_stuck_check_timeout() -> void:
	var distance_moved: float = parent.global_position.distance_to(_stuck_check_position)

	is_stuck = distance_moved < 0.1
	_stuck_check_position = parent.global_position

	if is_stuck:
		stuck.emit()