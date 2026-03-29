extends RayCast3D


@export var debug: bool = false

var current_object: Object = null


func _process(_delta: float) -> void:
	if not is_colliding():
		current_object = null
		return

	var collider: Object = get_collider()
	if collider != current_object:
		current_object = collider