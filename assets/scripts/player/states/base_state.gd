class_name PlayerState extends Node


@export var debug: bool = false

var player_controller: PlayerController


func _ready() -> void:
	# "%" means "Get the node in the scene with this unique name"
	if %StateMachine and %StateMachine is PlayerStateMachine:
		var state_machine: PlayerStateMachine = %StateMachine
		player_controller = state_machine.player_controller
	else:
		push_error("Missing StateMachine in current scene")