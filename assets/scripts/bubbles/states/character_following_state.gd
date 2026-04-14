extends Node


@export_category("References")
@export var character_bubble_emitter: CharacterBubbleEmitter


func _on_following_state_physics_processing(delta: float) -> void:
	character_bubble_emitter.update_follow_target_position()

	if character_bubble_emitter.nav_agent.is_navigation_finished():
		return

	character_bubble_emitter.move_to_target(delta)
