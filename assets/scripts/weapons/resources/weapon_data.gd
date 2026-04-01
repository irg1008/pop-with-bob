class_name WeaponData extends Resource


@export var weapon: Weapon
@export var unlocked: bool = false


var ammo: int:
  set(value): ammo = clamp(value, 0, weapon.max_ammo)
