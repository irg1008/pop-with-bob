@tool
class_name RigidHose3D
extends Path3D

@export_category("Attachments")
@export_node_path("Node3D") var attachment_start: NodePath
@export_node_path("Node3D") var attachment_end: NodePath

@export_category("Hose Properties")
@export var custom_initial_shape: bool = false :
	set(val): custom_initial_shape = val; _request_update()
@export var length: float = 5.0 :
	set(val): length = val; _request_update()
@export_range(3, 400) var segments: int = 20 :
	set(val): segments = val; _request_update()
@export var thickness: float = 0.1 :
	set(val): thickness = val; _request_update()
@export_range(4, 16) var radial_segments: int = 8 :
	set(val): radial_segments = val; _request_update()

@export_category("Simulation Tweaks")
@export var gravity: Vector3 = Vector3(0, -9.8, 0) :
	set(val): gravity = val; _request_update()
@export var damping: float = 0.98
@export_range(0.0, 1.0) var friction: float = 0.5
@export var stiffness_iterations: int = 15
@export_flags_3d_physics var collision_layer: int = 1
@export_flags_3d_physics var collision_mask: int = 1
@export var enable_self_collision: bool = false

@export_category("Rigid Body Extras")
@export var segment_mass: float = 0.5 :
	set(val): segment_mass = val; _request_update()
@export_range(0.0, 180.0) var bend_limit_degrees: float = 60.0 :
	set(val): bend_limit_degrees = val; _request_update()

var requires_update: bool = false

var _bodies: Array[RigidBody3D] = []
var _physics_container: Node3D
var csg_polygon: CSGPolygon3D

func _ready() -> void:
	if curve == null: curve = Curve3D.new()
	_setup_csg()
	_build_rope()

func _request_update() -> void:
	requires_update = true

func _setup_csg() -> void:
	for child in get_children():
		if child is CSGPolygon3D:
			csg_polygon = child
			break

	if not csg_polygon:
		csg_polygon = CSGPolygon3D.new()
		add_child(csg_polygon)
		if Engine.is_editor_hint():
			csg_polygon.owner = get_tree().edited_scene_root

	csg_polygon.mode = CSGPolygon3D.MODE_PATH
	csg_polygon.path_node = NodePath("..")
	csg_polygon.path_interval = 0.1
	csg_polygon.path_continuous_u = true
	csg_polygon.smooth_faces = true

	_update_csg_profile()

func _update_csg_profile() -> void:
	if not csg_polygon: return
	var profile = PackedVector2Array()
	for i in range(radial_segments):
		var angle = (float(i) / radial_segments) * PI * 2.0
		profile.append(Vector2(cos(angle), sin(angle)) * thickness)
	csg_polygon.polygon = profile

func _clear_physics() -> void:
	if is_instance_valid(_physics_container):
		_physics_container.queue_free()
	_bodies.clear()

func _build_rope() -> void:
	_clear_physics()

	if Engine.is_editor_hint():
		if custom_initial_shape and curve != null and curve.point_count > 0:
			length = curve.get_baked_length()
		else:
			_build_editor_preview()
		return

	_physics_container = Node3D.new()
	_physics_container.name = "PhysicsContainer"
	add_child(_physics_container)

	var s = get_node_or_null(attachment_start) as Node3D
	var e = get_node_or_null(attachment_end) as Node3D

	var s_body = _get_physics_body(s) if s else null
	var e_body = _get_physics_body(e) if e else null

	if custom_initial_shape and curve != null and curve.point_count > 0:
		length = curve.get_baked_length()
	if length <= 0.001: length = 0.001
	
	var segment_length = length / float(segments)

	# 1. Create Capsule Bodies
	for i in range(segments):
		var t_center = (float(i) + 0.5) / float(segments)
		var t_start = float(i) / float(segments)
		var t_end = float(i + 1) / float(segments)
		
		var p_center = Vector3.ZERO
		var p_start = Vector3.ZERO
		var p_end = Vector3.ZERO

		if custom_initial_shape and curve != null and curve.point_count > 0:	
			p_center = to_global(curve.sample_baked(length * t_center))
			p_start = to_global(curve.sample_baked(length * t_start))
			p_end = to_global(curve.sample_baked(length * t_end))
		else:
			var p1 = global_position
			var p2 = global_position + Vector3(0, -length, 0)
			if s: p1 = s.global_position
			if e: p2 = e.global_position
			p_center = p1.lerp(p2, t_center)
			p_start = p1.lerp(p2, t_start)
			p_end = p1.lerp(p2, t_end)

		var dir = (p_end - p_start).normalized()
		if dir.length_squared() < 0.1:
			dir = Vector3.UP

		var body = RigidBody3D.new()
		
		# Align the Y axis of the capsule with the curve direction
		var y_axis = dir
		var x_axis = Vector3.UP.cross(y_axis).normalized()
		if x_axis.length_squared() < 0.1:
			x_axis = Vector3.RIGHT.cross(y_axis).normalized()
		var z_axis = x_axis.cross(y_axis).normalized()
		body.global_transform = Transform3D(Basis(x_axis, y_axis, z_axis), p_center)

		body.mass = segment_mass
		body.linear_damp = 1.0 - damping
		body.angular_damp = 2.0
		# Apply custom gravity tweaking
		body.gravity_scale = gravity.length() / 9.8 if gravity.length() > 0 else 0.0
		
		if (i == 0 and s) or (i == segments - 1 and e):
			body.freeze = true
			body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

		body.collision_layer = collision_layer
		body.collision_mask = collision_mask

		if s_body: body.add_collision_exception_with(s_body)
		if e_body: body.add_collision_exception_with(e_body)

		var col = CollisionShape3D.new()
		var cap_shape = CapsuleShape3D.new()
		cap_shape.radius = thickness
		cap_shape.height = segment_length + (thickness * 0.1) 
		col.shape = cap_shape
		body.add_child(col)

		_physics_container.add_child(body)
		_bodies.append(body)

	# 2. Create 6DoF Joints
	for i in range(segments - 1):
		var joint = Generic6DOFJoint3D.new()
		_physics_container.add_child(joint)

		var t_joint = float(i + 1) / float(segments)
		var joint_pos = Vector3.ZERO
		
		var body_a = _bodies[i]
		var body_b = _bodies[i+1]

		if custom_initial_shape and curve != null and curve.point_count > 0:
			joint_pos = to_global(curve.sample_baked(length * t_joint))
		else:
			var p1 = global_position
			var p2 = global_position + Vector3(0, -length, 0)
			if s: p1 = s.global_position
			if e: p2 = e.global_position
			joint_pos = p1.lerp(p2, t_joint)
			
		joint.global_position = joint_pos
		joint.node_a = joint.get_path_to(body_a)
		joint.node_b = joint.get_path_to(body_b)

		# Lock Linear Motion everywhere
		for axis in [Vector3.AXIS_X, Vector3.AXIS_Y, Vector3.AXIS_Z]:
			joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
			joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
			joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
			
			joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
			joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)
			joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
			joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)
			joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
			joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)

		# Allow bend limits
		var limit_rad = deg_to_rad(bend_limit_degrees)
		joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
		joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
		joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)

		joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -limit_rad)
		joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, limit_rad)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -limit_rad)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, limit_rad)
		joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -limit_rad)
		joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, limit_rad)

func _build_editor_preview() -> void:
	if curve == null: return
	if custom_initial_shape: return # Don't overwrite the user's manual curve

	curve.clear_points()

	var p1 = global_position
	var p2 = global_position + Vector3(0, -length, 0)

	var s = get_node_or_null(attachment_start) as Node3D
	var e = get_node_or_null(attachment_end) as Node3D
	if s: p1 = s.global_position
	if e: p2 = e.global_position

	for i in range(segments + 1):
		var t = float(i) / float(segments)
		var p = to_local(p1.lerp(p2, t))
		curve.add_point(p)

func _process(delta: float) -> void:
	if requires_update:
		_build_rope()
		requires_update = false

	if Engine.is_editor_hint():
		if custom_initial_shape and curve != null and curve.point_count > 0:
			length = curve.get_baked_length()
		else:
			_build_editor_preview()
	else:
		_update_curve_from_physics()

func _update_curve_from_physics() -> void:
	if curve == null or _bodies.is_empty(): return
	curve.clear_points()
	
	var s = get_node_or_null(attachment_start) as Node3D
	var e = get_node_or_null(attachment_end) as Node3D

	var p_size = _bodies.size()

	# Start point
	if s:
		curve.add_point(to_local(s.global_position))
	else:
		curve.add_point(to_local(_bodies[0].global_position))

	# Mid points
	for i in range(1, p_size - 1):
		# We sample the position of the rigid bodies
		var p_current = to_local(_bodies[i].global_position)
		var p_in = Vector3.ZERO
		var p_out = Vector3.ZERO

		var prev = to_local(_bodies[i-1].global_position)
		var next = to_local(_bodies[i+1].global_position)
		var dir = (next - prev).normalized()

		var dist_prev = p_current.distance_to(prev) * 0.3
		var dist_next = p_current.distance_to(next) * 0.3

		p_in = -dir * dist_prev
		p_out = dir * dist_next

		curve.add_point(p_current, p_in, p_out)

	# End point
	if e:
		curve.add_point(to_local(e.global_position))
	else:
		curve.add_point(to_local(_bodies[-1].global_position))

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or _bodies.is_empty(): return

	var s = get_node_or_null(attachment_start) as Node3D
	var e = get_node_or_null(attachment_end) as Node3D

	# Pin the ends to the attachments
	if s and is_instance_valid(_bodies[0]):
		_bodies[0].global_position = s.global_position
	if e and is_instance_valid(_bodies[-1]):
		_bodies[-1].global_position = e.global_position

func _get_physics_body(node: Node) -> PhysicsBody3D:
	var curr = node
	while curr != null and curr != get_tree().root:
		if curr is PhysicsBody3D:
			return curr
		curr = curr.get_parent()
	return null

