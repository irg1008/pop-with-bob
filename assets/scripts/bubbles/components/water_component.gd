class_name WaterComponent extends Node


@export_category("References")
@export var bubble_emitter: BubbleEmitter
@export var water_progress_bar: ProgressBar

@export_category("Water Properties")
@export var initial_water: float = 100.0


var current_water: float = 0.0


func _ready() -> void:
	current_water = initial_water
	water_progress_bar.value = current_water


func use_water() -> void:
	if current_water <= 0.0:
		return

	current_water = max(0.0, current_water - bubble_emitter.water_per_bubble)
	water_progress_bar.value = lerp(water_progress_bar.value, current_water, 0.1)