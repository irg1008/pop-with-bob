extends WeaponState


func _on_weapon_empty_state_entered() -> void:
	print("Weapon is empty!")


func _on_empty_state_processing(_delta: float) -> void:
	pass