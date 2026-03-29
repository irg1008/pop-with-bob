class_name PlayerStateMachine extends Node


@export_category("References")
@export var player_controller: PlayerController


func _process(_delta: float) -> void:
	if player_controller:
		player_controller.state_chart.set_expression_property("Player velocity", player_controller.velocity)
		player_controller.state_chart.set_expression_property("Player Hitting Head", player_controller.crouch_check.is_colliding())

		var looking_at: Object = player_controller.interaction_raycast.current_object;
		player_controller.state_chart.set_expression_property("Looking at: ", looking_at)