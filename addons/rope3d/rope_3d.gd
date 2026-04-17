@tool
class_name Rope3D
extends Path3D

## Emitted if we need specific gameplay triggers, though physics handles stretching natively now
signal anchor_distanced(offset: Vector3)

# ── Exported Parameters ──────────────────────────────────────────────────

@export_category("Rope Core")
## Quality maps segment length from 0.5m (0.0) to 0.1m (1.0). Total segments is automatically derived from the path's length.
@export_range(0.0, 1.0) var quality: float = 0.5:
	set(val): quality = val; _request_update()

## Radius of the rope capsule bodies.
@export var thickness: float = 0.1:
	set(val): thickness = val; _request_update()

## Controls how tightly the solver prevents the rigidbodies from separating. 1.0 = strict distance.
@export_range(0.0, 1.0) var rigidity: float = 1.0

## Visual detail across the cylinder's circumference.
@export_range(3, 16) var radial_segments: int = 8:
	set(val): radial_segments = val; _request_update()

@export_category("Physics Properties")
## Total mass of the rope, distributed evenly across all generated segments.
@export var total_mass: float = 10.0:
	set(val): total_mass = val; _request_update()

## Surface friction for environmental collisions (Jolt).
@export_range(0.0, 1.0) var friction: float = 0.5

@export_flags_3d_physics var collision_layer: int = 1
@export_flags_3d_physics var collision_mask: int = 1

@export_category("Anchors")
## The Node3D to pin the start of the rope to.
@export_node_path("Node3D") var attachment_start: NodePath:
	set(val):
		attachment_start = val
		_request_update()

## The Node3D to pin the end of the rope to. Only valid if distance from start <= Path length.
@export_node_path("Node3D") var attachment_end: NodePath:
	set(val):
		attachment_end = val
		if Engine.is_editor_hint() or _bodies.is_empty():
			_request_update()
		else:
			_validate_end_anchor_dynamic()

@export_category("Custom Segments")
## Completely replaces the FIRST generated rope segment with your own RigidBody3D. It physically joins the solver chain.
@export_node_path("RigidBody3D") var custom_body_start: NodePath:
	set(val):
		custom_body_start = val
		_request_update()

## Completely replaces the LAST generated rope segment with your own RigidBody3D. It physically joins the solver chain.
@export_node_path("RigidBody3D") var custom_body_end: NodePath:
	set(val):
		custom_body_end = val
		_request_update()

@export_category("Debug")
@export var show_debug_meshes: bool = false:
	set(val): show_debug_meshes = val; _request_update()

# ── Internal State ───────────────────────────────────────────────────────

var _bodies: Array[RigidBody3D] = []
var _physics_container: Node3D
var _csg_polygon: CSGPolygon3D
var _debug_label: Label3D
var _requires_update: bool = false

var _segment_length: float = 0.0
var _total_length: float = 0.0
var _valid_end_anchor: Node3D = null

# ─────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	if curve == null:
		curve = Curve3D.new()

	_setup_csg()

	if not Engine.is_editor_hint():
		_build_rope()

func _process(_delta: float) -> void:
	if _requires_update:
		_setup_csg()
		_requires_update = false

	if not Engine.is_editor_hint():
		_sync_curve_to_physics()
		
		if show_debug_meshes:
			if not is_instance_valid(_debug_label):
				_debug_label = Label3D.new()
				add_child(_debug_label)
				_debug_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				_debug_label.pixel_size = 0.005
				_debug_label.no_depth_test = true
			
			if _bodies.size() >= 3:
				var dist_to_anchor := 0.0
				
				if is_instance_valid(_valid_end_anchor):
					dist_to_anchor = _bodies[-1].global_position.distance_to(_valid_end_anchor.global_position)
				
				var stretch_allowed := lerpf(0.5, 0.12, rigidity)
				var is_attached := dist_to_anchor > stretch_allowed + 0.02

				_debug_label.global_position = _bodies[int(_bodies.size() / 2.0)].global_position + Vector3.UP * 0.5
				_debug_label.modulate = Color.WHITE if is_attached else Color.RED
				_debug_label.text = "Attached: %s\nAnchor Distance: %.3fm" % [
					str(is_attached), dist_to_anchor
				]
		elif is_instance_valid(_debug_label):
			_debug_label.queue_free()

func _request_update() -> void:
	_requires_update = true

# ── Visuals ──────────────────────────────────────────────────────────────

func _setup_csg() -> void:
	for child in get_children():
		if child is CSGPolygon3D:
			_csg_polygon = child
			break

	if not is_instance_valid(_csg_polygon):
		_csg_polygon = CSGPolygon3D.new()
		add_child(_csg_polygon)
		if Engine.is_editor_hint():
			_csg_polygon.owner = get_tree().edited_scene_root

	_csg_polygon.mode = CSGPolygon3D.MODE_PATH
	_csg_polygon.path_node = NodePath("..")
	_csg_polygon.path_interval = 0.1
	_csg_polygon.path_continuous_u = true
	_csg_polygon.smooth_faces = true

	var profile = PackedVector2Array()
	for i in range(radial_segments):
		var angle := (float(i) / radial_segments) * PI * 2.0
		profile.append(Vector2(cos(angle), sin(angle)) * thickness)
	_csg_polygon.polygon = profile

	if show_debug_meshes:
		var mat = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1, 1, 1, 0.15)
		_csg_polygon.material = mat
	else:
		_csg_polygon.material = null

func _sync_curve_to_physics() -> void:
	if curve == null or _bodies.is_empty():
		return
	curve.clear_points()

	var s := get_node_or_null(attachment_start) as Node3D

	# Start point
	if s:
		curve.add_point(to_local(s.global_position))
	else:
		curve.add_point(to_local(_bodies[0].global_position))

	# Mid points
	for i in range(1, _bodies.size() - 1):
		var prev := to_local(_bodies[i - 1].global_position)
		var curr := to_local(_bodies[i].global_position)
		var next := to_local(_bodies[i + 1].global_position)
		
		var dir := (next - prev).normalized()
		var dist_prev := curr.distance_to(prev) * 0.3
		var dist_next := curr.distance_to(next) * 0.3
		
		curve.add_point(curr, -dir * dist_prev, dir * dist_next)

	# End point: Now perfectly matching the physics body rather than teleporting to the player!
	curve.add_point(to_local(_bodies[-1].global_position))

func _validate_end_anchor_dynamic() -> void:
	if _bodies.is_empty(): return
	var e := get_node_or_null(attachment_end) as Node3D
	
	if e:
		_valid_end_anchor = e
		# Optionally reset wake state so attachment immediately evaluates physically
		if is_instance_valid(_bodies[-1]):
			_bodies[-1].sleeping = false
	else:
		_valid_end_anchor = null

# ── Physics Generation ───────────────────────────────────────────────────

func _clear_physics() -> void:
	if is_instance_valid(_physics_container):
		_physics_container.queue_free()
	if is_instance_valid(_debug_label):
		_debug_label.queue_free()
	_bodies.clear()
	_valid_end_anchor = null

func _build_rope() -> void:
	_clear_physics()

	if curve == null or curve.point_count < 2:
		return

	_total_length = curve.get_baked_length()
	if _total_length <= 0.001:
		return

	_physics_container = Node3D.new()
	_physics_container.name = "PhysicsContainer"
	add_child(_physics_container)

	# Quality inversely interpolates segment length. 1.0 quality = 0.1m, 0.0 quality = 0.5m
	_segment_length = lerpf(0.5, 0.1, quality)
	
	# Derive segment count
	var segment_count := maxi(2, roundi(_total_length / _segment_length))
	# Recalculate true segment length to perfectly fit the calculated count
	_segment_length = _total_length / float(segment_count)

	var s := get_node_or_null(attachment_start) as Node3D
	var e := get_node_or_null(attachment_end) as Node3D
	
	if e:
		_valid_end_anchor = e

	var phys_mat := PhysicsMaterial.new()
	phys_mat.friction = friction

	# Spawn rigid bodies along the curve
	for i in range(segment_count):
		var t_center := (float(i) + 0.5) / float(segment_count)
		var p_center := to_global(curve.sample_baked(_total_length * t_center))

		var t_start := float(i) / float(segment_count)
		var t_end := float(i + 1) / float(segment_count)
		var p_start := to_global(curve.sample_baked(_total_length * t_start))
		var p_end := to_global(curve.sample_baked(_total_length * t_end))

		var dir := (p_end - p_start).normalized()
		if dir.length_squared() < 0.1: dir = Vector3.UP
		var y_axis := dir
		var x_axis := Vector3.UP.cross(y_axis).normalized()
		if x_axis.length_squared() < 0.1: x_axis = Vector3.RIGHT.cross(y_axis).normalized()
		var z_axis := x_axis.cross(y_axis).normalized()

		var is_custom_start := (i == 0 and not custom_body_start.is_empty())
		var is_custom_end := (i == segment_count - 1 and not custom_body_end.is_empty())

		var body: RigidBody3D = null
		if is_custom_start:
			body = get_node_or_null(custom_body_start) as RigidBody3D
		elif is_custom_end:
			body = get_node_or_null(custom_body_end) as RigidBody3D

		var is_generated := false
		if not is_instance_valid(body):
			body = RigidBody3D.new()
			is_generated = true

		if is_generated:
			body.global_transform = Transform3D(Basis(x_axis, y_axis, z_axis), p_center)
			body.mass = maxf(total_mass / float(segment_count), 0.05)
			body.physics_material_override = phys_mat
			body.collision_layer = collision_layer
			body.collision_mask = collision_mask
			body.continuous_cd = true
			body.contact_monitor = true
			body.max_contacts_reported = 4

			body.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
			body.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
			body.linear_damp = 1.0
			body.angular_damp = 2.0

			var col := CollisionShape3D.new()
			var cap := CapsuleShape3D.new()
			cap.radius = thickness
			cap.height = maxf(_segment_length * 0.85, thickness * 2.0)
			col.shape = cap
			body.add_child(col)

			if show_debug_meshes:
				var mi := MeshInstance3D.new()
				var cm := CapsuleMesh.new()
				cm.radius = thickness
				cm.height = _segment_length
				var mat := StandardMaterial3D.new()
				mat.albedo_color = Color(1.0, 0.2, 0.2, 0.7)
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				cm.surface_set_material(0, mat)
				mi.mesh = cm
				body.add_child(mi)

			_physics_container.add_child(body)
			
		_bodies.append(body)

	var cb_start := get_node_or_null(custom_body_start) as RigidBody3D
	var cb_end := get_node_or_null(custom_body_end) as RigidBody3D
	for b in _bodies:
		if is_instance_valid(cb_start) and b != cb_start:
			cb_start.add_collision_exception_with(b)
			b.add_collision_exception_with(cb_start)
		if is_instance_valid(cb_end) and b != cb_end:
			cb_end.add_collision_exception_with(b)
			b.add_collision_exception_with(cb_end)

# ── Physics Constraint Loop ──────────────────────────────────────────────

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or _bodies.is_empty():
		return

	var s := get_node_or_null(attachment_start) as Node3D
	
	# Continuous End Anchor Tracking
	if is_instance_valid(_valid_end_anchor) and _bodies.size() >= 3:
		var offset := _valid_end_anchor.global_position - _bodies[-2].global_position
		if offset.length() > 0.05:
			anchor_distanced.emit(offset)

	# Start anchor pinning (overrides engine physics)
	if s and is_instance_valid(_bodies[0]):
		_bodies[0].global_position = s.global_position
		_bodies[0].linear_velocity = Vector3.ZERO
		_bodies[0].angular_velocity = Vector3.ZERO
		
		# Prevent internal fighting between pinned head and colliding anchor body
		var s_phys := _find_physics_body(s)
		if s_phys: _bodies[0].add_collision_exception_with(s_phys)

	# Store previous positions to derive accurate XPBD velocities
	var prev_positions: Array[Vector3] = []
	for body in _bodies:
		prev_positions.append(body.global_position)

	# Pure Bidirectional Verlet Positional Solver
	var max_iters := int(lerpf(10.0, 30.0, rigidity))
	# 1. DRIVER: Apply the Anchor pull exactly once per physics frame.
	if is_instance_valid(_valid_end_anchor) and _bodies.size() > 0:
		var body_end := _bodies[-1]
		var anchor_pos := _valid_end_anchor.global_position
		body_end.global_position = body_end.global_position.lerp(anchor_pos, 0.8)
	
	for _iter in range(max_iters):
		# 2. RIGIDIFIER: Enforce 0cm resting gaps across the entire chain
		var is_reverse := (_iter % 2 == 1)
		var body_count := _bodies.size() - 1
		
		for step in range(body_count):
			var i = (body_count - 1 - step) if is_reverse else step
			var a := _bodies[i]
			var b := _bodies[i + 1]
			
			var diff := b.global_position - a.global_position
			var dist := diff.length()
			if dist < 0.0001:
				b.global_position += Vector3.DOWN * 0.01
				continue

			var error := 0.0
			
			# Add slack threshold to allow string to naturally compress or bunch up
			if dist < _segment_length * 0.85:
				error = dist - (_segment_length * 0.85)
			# Strictly penalize stretching beyond allowed rigid segment length
			elif dist > _segment_length:
				error = dist - _segment_length
			else:
				continue

			var dir := diff / dist
			var stiffness := lerpf(0.5, 1.0, rigidity)
			var half_err := (error * 0.5) * stiffness
			error *= stiffness

			# Evaluate pin conditions
			var a_pinned: bool = (i == 0 and s != null)

			if a_pinned:
				b.global_position -= dir * error
			else:
				a.global_position += dir * half_err
				b.global_position -= dir * half_err

	# XPBD Velocity Update: Tell Jolt about the forces we applied so it fights gravity!
	for i in range(_bodies.size()):
		var body := _bodies[i]
		if i == 0 and s != null: continue
		if i == _bodies.size() - 1 and _valid_end_anchor != null: continue
		
		# ADD the solver's movement correction to the existing velocity.
		# If we just use '=', we destroy Jolt's gravity momentum when the rope is slack!
		body.linear_velocity += (body.global_position - prev_positions[i]) / _delta

	# Body Orientations
	for i in range(_bodies.size()):
		var body := _bodies[i]
		if i == 0 and s != null: continue
		if i == _bodies.size() - 1 and _valid_end_anchor != null: continue
		
		var chain_dir: Vector3
		if i < _bodies.size() - 1:
			chain_dir = (_bodies[i + 1].global_position - body.global_position).normalized()
		else:
			chain_dir = (body.global_position - _bodies[i - 1].global_position).normalized()
		
		if chain_dir.length_squared() >= 0.01:
			var y := chain_dir
			# Only update transform if the angle changed significantly (~1 degree).
			# Setting global_transform breaks physics sleep states and friction if done every frame.
			if body.global_transform.basis.y.dot(y) < 0.9995:
				var x := Vector3.UP.cross(y).normalized()
				if x.length_squared() < 0.01: x = Vector3.RIGHT.cross(y).normalized()
				var z := x.cross(y).normalized()
				body.global_transform = Transform3D(Basis(x, y, z), body.global_position)

func _find_physics_body(n: Node) -> PhysicsBody3D:
	var curr := n
	while curr and curr != get_tree().root:
		if curr is PhysicsBody3D: return curr
		curr = curr.get_parent()
	return null
