extends WeaponState


func _on_firing_state_entered() -> void:
	weapon_controller.fire_weapon()


func _on_firing_state_physics_processing(_delta: float) -> void:
	if weapon_controller.current_ammo <= 0:
		weapon_controller.weapon_state_chart.send_event("onEmpty")
		return

	var is_automatic: bool = weapon_controller.current_weapon.is_automatic

	if not is_automatic or not Input.is_action_pressed("fire"):
		weapon_controller.weapon_state_chart.send_event("onIdle")
		return

	if weapon_controller.can_fire():
		weapon_controller.fire_weapon()
