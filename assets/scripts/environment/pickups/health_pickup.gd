class_name HealthPickup extends BasePickup


@export_category("Health Pickup Settings")
@export var health_amount: float = 25.0

func can_pickup(player: Node3D) -> bool:
	if player is PlayerController:
		return not player.health_component.is_full_health()

	return false

func apply_pickup(player: Node3D) -> void:
	if player is PlayerController:
		player.health_component.heal(health_amount)