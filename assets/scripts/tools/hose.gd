extends Node


@onready var watering_area: Area3D = $WateringArea
@onready var water_spray: GPUParticles3D = $WaterSpray


var pouring: bool = false


func _ready() -> void:
	water_spray.emitting = false


func _physics_process(delta: float) -> void:
	pouring = Input.is_action_pressed("pour_water")

	water_spray.emitting = pouring

	if pouring:
		_pour_water(delta)


func _pour_water(delta: float) -> void:
	for body: Node3D in watering_area.get_overlapping_bodies():
		var receiver: Node = body.find_child("WaterComponent")
		if receiver and receiver is WaterComponent:
			receiver.receive_water(delta)
