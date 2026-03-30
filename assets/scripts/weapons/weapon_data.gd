class_name WeaponData extends Resource


@export var weapon: Weapon
@export var unlocked: bool = false
@export var ammo: int = 0:
  set(value): ammo = clamp(value, 0, weapon.max_ammo)