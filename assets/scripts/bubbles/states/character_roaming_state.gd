extends Node


@export_category("References")
@export var character_bubble_emitter: CharacterBubbleEmitter


func _on_roaming_state_physics_processing(delta: float) -> void:
	if character_bubble_emitter.nav_agent.is_navigation_finished():
		character_bubble_emitter.set_new_roam_target()
		return

	character_bubble_emitter.move_to_target(delta)


func _on_roaming_state_entered() -> void:
	if character_bubble_emitter.nav_agent.is_navigation_finished():
		character_bubble_emitter.set_new_roam_target()

	if character_bubble_emitter.animation_state.get_current_node() != "Roaming":
		character_bubble_emitter.animation_state.travel("Roaming")
