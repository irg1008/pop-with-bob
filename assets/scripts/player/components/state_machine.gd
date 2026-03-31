class_name PlayerStateMachine extends Node


@export_category("References")
@export var player_controller: PlayerController


func _ready() -> void:
	setup_children_controller()


func _process(_delta: float) -> void:
	if player_controller:
		player_controller.state_chart.set_expression_property("Player health", player_controller.health_component.current_health)
		player_controller.state_chart.set_expression_property("Player velocity", player_controller.velocity)
		player_controller.state_chart.set_expression_property("Player Hitting Head", player_controller.crouch_check.is_colliding())

		var looking_at: Object = player_controller.interaction_raycast.current_object;
		player_controller.state_chart.set_expression_property("Looking at: ", looking_at)


func setup_children_controller() -> void:
	if not player_controller:
		push_error("PlayerStateMachine needs a reference to the PlayerController")
		return

	for state: PlayerState in find_children("*", "PlayerState", true, false):
			state.player_controller = player_controller
