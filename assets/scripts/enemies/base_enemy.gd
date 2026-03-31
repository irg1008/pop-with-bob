@abstract
class_name BaseEnemy extends SmoothStairsCharacter3D


@export var enemy_groups: Array[String] = []


@abstract func _on_triggered() -> void


func _ready() -> void:
	for group: String in enemy_groups:
		add_to_group(group)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	smooth_move_and_stair_step()


func _on_smooth_step(previous_height: float, _height_delta: float) -> void:
	var delta: float = get_physics_process_delta_time()
	position.y = lerp(previous_height, position.y, 8.0 * delta)
