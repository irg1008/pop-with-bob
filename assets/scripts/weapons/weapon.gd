class_name Weapon extends Resource



@export_category("Weapon Settings")
@export var damage: float = 25.0
@export var max_ammo: int = 12
@export var weapon_name: String = "Pistol"
@export var weapon_model: PackedScene
@export var weapon_position: Vector3 = Vector3(0.2, -0.2, -0.3)

@export_category("Firing Mode")
@export_group("Hitscan")
@export var is_hitscan: bool = true
@export var hitscan_range: float = 25.0
@export_group("Projectile")
@export var projectile_speed: float = 50.0
@export var projectile_scene: PackedScene