extends WeaponState


func _on_idle_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_pressed("fire") and weapon_controller.can_fire():
		weapon_controller.weapon_state_chart.send_event("onFiring")

	if weapon_controller.current_ammo <= 0:
		weapon_controller.weapon_state_chart.send_event("onEmpty")
