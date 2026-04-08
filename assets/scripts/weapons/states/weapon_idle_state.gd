extends WeaponState


func _on_idle_state_physics_processing(_delta: float) -> void:
	if Managers.is_input_locked():
		return

	if Input.is_action_just_pressed("fire") and weapon_controller.can_fire():
		weapon_controller.weapon_state_chart.send_event("onFiring")

	if not weapon_controller.has_ammo():
		weapon_controller.weapon_state_chart.send_event("onEmpty")
