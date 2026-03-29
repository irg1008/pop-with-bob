@tool
extends Control


@export var radius: float = 30.0: set = set_crosshair_radius
@export var thickness: float = 1.0: set = set_crosshair_thickness
@export var color: Color = Color.WHITE: set = set_crosshair_color
@export var gap_angle: float = 45.0: set = set_crosshair_gap_angle
@export var segments: int = 32: set = set_crosshair_segments


func _draw() -> void:
	draw_circle_crosshair()


func draw_circle_crosshair() -> void:
	var gap_rad: float = deg_to_rad(gap_angle)

	var arc_segments: Array = [
		# Bottom right
		[gap_rad / 2, PI / 2 - gap_rad / 2],
		# Bottom left
		[PI / 2 + gap_rad / 2, PI - gap_rad / 2],
		# Top left
		[PI + gap_rad / 2, 3 * PI / 2 - gap_rad / 2],
		# Top right
		[3 * PI / 2 + gap_rad / 2, 2 * PI - gap_rad / 2]
	]

	for arc: Array in arc_segments:
		var start_angle: float = arc[0]
		var end_angle: float = arc[1]
		draw_arc(Vector2.ZERO, radius, start_angle, end_angle, segments, color, thickness, true)


func update_crosshair() -> void:
	queue_redraw()


func set_crosshair_radius(new_radius: float) -> void:
	radius = new_radius
	update_crosshair()


func set_crosshair_thickness(new_thickness: float) -> void:
	thickness = new_thickness
	update_crosshair()


func set_crosshair_color(new_color: Color) -> void:
	color = new_color
	update_crosshair()


func set_crosshair_gap_angle(new_gap_angle: float) -> void:
	gap_angle = new_gap_angle
	update_crosshair()


func set_crosshair_segments(new_segments: int) -> void:
	segments = new_segments
	update_crosshair()
