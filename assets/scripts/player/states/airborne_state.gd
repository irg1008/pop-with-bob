extends PlayerState


func _on_airborne_state_physics_processing(_delta: float) -> void:
	if player_controller.is_on_floor():
		player_controller.state_chart.send_event("onGrounded")

		if player_controller.check_fall_speed():
			player_controller.camera_effects.add_fall_kick()

	# Update fall speed here since it holds previous frame's speed
	player_controller.update_fall_speed()
