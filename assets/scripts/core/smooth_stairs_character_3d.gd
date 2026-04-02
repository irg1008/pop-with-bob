class_name SmoothStairsCharacter3D extends StairsCharacter3D


const MIN_STEP_HEIGHT: float = 0.05
const STEP_HEIGHT_MARGIN: float = 0.001


func smooth_move_and_stair_step() -> void:
	var previous_height: float = position.y
	move_and_stair_step()

	var new_height: float = position.y
	var height_delta: float = new_height - previous_height
	var rounded_height_delta: float = snapped(absf(height_delta), STEP_HEIGHT_MARGIN)

	var step_height: float = step_height_up if height_delta > 0 else step_height_down
	var is_step: bool = rounded_height_delta > MIN_STEP_HEIGHT and rounded_height_delta <= step_height

	if is_on_floor() and is_step:
		var delta: float = get_physics_process_delta_time()
		_on_smooth_step(delta, previous_height, height_delta)


func _on_smooth_step(_delta: float, _previous_height: float, _height_delta: float) -> void:
	pass