class_name Weapon extends Resource


@export_category("Weapon Settings")
@export var weapon_name: String = "Pistol"
@export var weapon_scene: PackedScene
@export var weapon_position: Vector3 = Vector3(0.2, -0.2, -0.3)

@export_category("Weapon Stats")
@export_range(0, 100, 1, "suffix:%") var accuracy: int = 100
@export var damage: float = 25.0
@export var max_ammo: int = 12
@export_group("Fire Rate")
@export_range(0.1, 200.0, 0.1) var fire_rate: float = 2.0
@export var is_automatic: bool = false
@export_group("Projectile")
@export var projectile_speed: float = 50.0
@export var projectile_scene: PackedScene
@export_group("Hitscan")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var is_hitscan: bool = false
@export var hitscan_range: float = 25.0
@export_subgroup("Spread Settings")
@export var pellet_count: int = 1
@export var spread_angle: float = 0.0
