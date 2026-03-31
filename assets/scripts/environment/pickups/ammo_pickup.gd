class_name AmmoPickup extends BasePickup


@export_category("Ammo Pickup Settings")
@export var weapon: Weapon
@export var ammo_amount: int = 10

func can_pickup(_body: Node3D) -> bool:
	var weapon_data: WeaponData = Managers.weapon_manager.get_data_for_weapon(weapon)
	if not weapon_data:
		return false

	return not weapon_data.unlocked or weapon_data.ammo < weapon.max_ammo


func apply_pickup(_body: Node3D) -> void:
	var weapon_data: WeaponData = Managers.weapon_manager.get_data_for_weapon(weapon)
	Managers.weapon_manager.add_ammo(weapon_data, ammo_amount)
