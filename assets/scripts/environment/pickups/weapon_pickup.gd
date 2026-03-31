class_name WeaponPickup extends BasePickup


@export_category("Weapon Pickup Settings")
@export var weapon: Weapon


func can_pickup(_body: Node3D) -> bool:
	var weapon_data: WeaponData = Managers.weapon_manager.get_data_for_weapon(weapon)
	if not weapon_data:
		return false

	return not weapon_data.unlocked or weapon_data.ammo < weapon.max_ammo


func apply_pickup(_body: Node3D) -> void:
	var weapon_data: WeaponData = Managers.weapon_manager.get_data_for_weapon(weapon)
	if not weapon_data:
		return

	if not weapon_data.unlocked:
		Managers.weapon_manager.unlock_weapon(weapon_data)
		Managers.weapon_manager.switch_weapon(weapon_data)

	Managers.weapon_manager.refill_max_ammo(weapon_data)
