extends Node3D


@export var max_flow_amount: float = 1.0


@onready var watering_area: Area3D = $WateringArea
@onready var water_spray: GPUParticles3D = $WaterSpray


var current_flow: float = 0.0
var pouring: bool = false


func _ready() -> void:
	water_spray.emitting = false


func _physics_process(delta: float) -> void:
	pouring = Input.is_action_pressed("pour_water")

	if pouring:
		_pour_water(delta)
		current_flow = lerp(current_flow, max_flow_amount, delta * 3.0)
	else:
		current_flow = lerp(current_flow, 0.0, delta * 10.0)

	water_spray.amount_ratio = current_flow
	# water_spray.process_material.scale_min = 0.05 + (current_flow * 0.03)
	water_spray.emitting = current_flow > 0.01


func _pour_water(delta: float) -> void:
	for body: Node3D in watering_area.get_overlapping_bodies():
		var receiver: Node = body.find_child("WaterComponent")
		if receiver and receiver is WaterComponent:
			receiver.receive_water(delta)
