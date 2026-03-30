class_name BasePickup extends Area3D


@export var rotation_speed: float = 60.0
@export var float_height: float = 0.1
@export var float_speed: float = 2.0


var start_y: float
var time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_pickup)
	start_y = position.y


func _process(delta: float) -> void:
	pass


func _on_pickup(body: Node3D) -> void:
	if not body is PlayerController:
		return

	if can_pickup(body):
		apply_pickup(body)
		queue_free()


func can_pickup(_body: Node3D) -> bool:
	return true


func apply_pickup(_body: Node3D) -> void:
	pass