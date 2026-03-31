class_name HealthComponent extends Node

## Reusable health component for any entity (player, enemies, destructibles, etc.)


signal health_changed(new_health: int, max_health: int)
signal damage_taken(amount: int, source: Node3D)
signal died()


@export var max_health: float = 100.0
@export var start_at_max: bool = true


var current_health: float = 0.0
var is_alive: bool = true


func _ready() -> void:
	if start_at_max:
		current_health = max_health


func take_damage(amount: float, source: Node3D) -> void:
	if not is_alive or amount <= 0.0:
		return

	var actual_damage: float = max(0.0, amount)
	current_health = max(0.0, current_health - actual_damage)

	damage_taken.emit(actual_damage, source)
	health_changed.emit(current_health, max_health)

	print("Took damage: %f, current health: %f" % [actual_damage, current_health])

	if current_health <= 0.0:
		_handle_death()


func heal(amount: float) -> void:
	if not is_alive or amount <= 0.0:
		return

	var actual_heal: float = max(0.0, amount)
	current_health = min(max_health, current_health + actual_heal)

	health_changed.emit(current_health, max_health)


func _handle_death() -> void:
	if not is_alive:
		return

	is_alive = false
	current_health = 0.0
	died.emit()

	print("Entity died")