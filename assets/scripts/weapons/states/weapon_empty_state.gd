extends WeaponState


func _on_empty_state_processing(_delta: float) -> void:
	if weapon_controller.has_ammo():
		weapon_controller.weapon_state_chart.send_event("onIdle")