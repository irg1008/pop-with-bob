class_name WaterComponent extends Node


signal water_depleted()
signal water_refilled()
signal water_changed(current_water: float)

@export_category("References")
@export var water_progress_bar: ProgressBar
@export var water_amount_label: Label

@export_category("Water Properties")
@export var initial_water: float = 100.0
@export var max_water: float = 100.0
@export var water_use_rate: float = 2.0
@export var water_absorption_rate: float = 5.0


var current_water: float = 0.0: set = set_current_water


func set_current_water(value: float) -> void:
	current_water = clamp(value, 0.0, max_water)
	water_progress_bar.value = current_water / max_water * 100.0
	water_amount_label.text = "%d / %d" % [roundi(current_water), roundi(max_water)]

	if current_water <= 0.0:
		water_depleted.emit()
	elif current_water >= max_water:
		water_refilled.emit()

	water_changed.emit(current_water)


func _ready() -> void:
	current_water = initial_water


func _process(delta: float) -> void:
	if current_water <= max_water and water_use_rate > 0.0:
		use_water(water_use_rate * delta)


func use_water(amount: float) -> void:
	if current_water <= 0.0:
		return

	current_water -= amount


func receive_water(delta: float) -> void:
	if current_water >= max_water:
		return

	current_water += water_absorption_rate * delta



func refill_water() -> void:
	current_water = max_water
