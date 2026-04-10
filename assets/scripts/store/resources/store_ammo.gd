class_name StoreAmmo extends StoreItem


@export var weapon: Weapon
@export var ammo: int = 5


func format_text() -> String:
	return "{name} ({ammo}) - {price} {currency}".format({
		"name": name,
		"price": price,
		"currency": StoreItem.get_currency_label(currency),
		"ammo": ammo,
	})


func on_purchased() -> void:
	var weapon_data: WeaponData = Managers.weapon_manager.get_weapon_data(weapon)
	Managers.weapon_manager.add_ammo(weapon_data, ammo)


func can_purchase() -> bool:
	var weapon_data: WeaponData = Managers.weapon_manager.get_weapon_data(weapon)
	var has_max_ammo: bool = weapon_data.ammo >= weapon_data.weapon.max_ammo
	return weapon_data.unlocked and not has_max_ammo
