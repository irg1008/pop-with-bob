@tool
class_name Hose3D
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
	set(val): thickness = val; _update_csg_profile()
@export_range(4, 16) var radial_segments: int = 8 :
	set(val): radial_segments = val; _update_csg_profile()

@export_category("Simulation Tweaks")
@export var gravity: Vector3 = Vector3(0, -9.8, 0)
@export var damping: float = 0.98
@export_range(0.0, 1.0) var friction: float = 0.5
@export var stiffness_iterations: int = 15
@export_flags_3d_physics var collision_mask: int = 1
@export var enable_self_collision: bool = false

var pos: PackedVector3Array
var old_pos: PackedVector3Array
var csg_polygon: CSGPolygon3D
var requires_update: bool = false

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

func _build_rope() -> void:
	pos.clear()
	old_pos.clear()
	
	if custom_initial_shape and curve != null and curve.point_count > 0:
		length = curve.get_baked_length()
		if length <= 0.001: length = 0.001
		
		for i in range(segments + 1):
			var t = float(i) / float(segments)
			var p = to_global(curve.sample_baked(length * t))
			pos.append(p)
			old_pos.append(p)
	else:
		var p1 = global_position
		var p2 = global_position + Vector3(0, -length, 0)
		var s = get_node_or_null(attachment_start) as Node3D
		var e = get_node_or_null(attachment_end) as Node3D
		if s: p1 = s.global_position
		if e: p2 = e.global_position
		
		for i in range(segments + 1):
			var t = float(i) / float(segments)
			var p = p1.lerp(p2, t)
			pos.append(p)
			old_pos.append(p)
			
		_update_curve()

func _update_curve() -> void:
	if curve == null or pos.is_empty(): return
	curve.clear_points()
	var p_size = pos.size()
	for i in range(p_size):
		var p_current = to_local(pos[i])
		var p_in = Vector3.ZERO
		var p_out = Vector3.ZERO
		
		# Add curve tangents to round out the sharp angles at the joints
		if i > 0 and i < p_size - 1:
			var prev = to_local(pos[i-1])
			var next = to_local(pos[i+1])
			var dir = (next - prev).normalized()
			
			# 0.3 is a smoothing factor. Higher = loopier bends, Lower = sharper bends.
			var dist_prev = p_current.distance_to(prev) * 0.3
			var dist_next = p_current.distance_to(next) * 0.3
			
			p_in = -dir * dist_prev
			p_out = dir * dist_next
			
		curve.add_point(p_current, p_in, p_out)

func _process(_delta: float) -> void:
	if requires_update:
		_build_rope()
		requires_update = false
		
	if Engine.is_editor_hint():
		if custom_initial_shape:
			if curve != null and curve.point_count > 0:
				length = curve.get_baked_length()
		else:
			var s = get_node_or_null(attachment_start) as Node3D
			var e = get_node_or_null(attachment_end) as Node3D
			if s: pos[0] = s.global_position
			if e: pos[-1] = e.global_position
			_update_curve()
	else:
		# Sync visual line with simulation smooth
		_update_curve()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or pos.size() < 2: return
	
	var space_state = get_world_3d().direct_space_state
	var segment_length = length / float(max(1, segments))
	
	var s = get_node_or_null(attachment_start) as Node3D
	var e = get_node_or_null(attachment_end) as Node3D
	
	# PRE-ALLOCATION OPTIMIZATIONS:
	# Avoid creating thousands of new raycast objects per frame by reusing them!
	var query = PhysicsRayQueryParameters3D.new()
	query.collision_mask = collision_mask
	var down_query = PhysicsRayQueryParameters3D.new()
	down_query.collision_mask = collision_mask
	
	var p_size = pos.size()
	var p_last = p_size - 1
	# The distance MUST be at least 2.0 * thickness, because thickness is the radius of the tube!
	# Less than 2.0 means the visual meshes will overlap and slip through each other.
	var min_dist = max(thickness * 2.0, segment_length * 0.8)
	var min_dist_sq = min_dist * min_dist
	var delta_sq = delta * delta
	var half_thickness = thickness * 0.5

	# 1. Verlet Integration
	for i in range(p_size):
		if (s and i == 0) or (e and i == p_last):
			if s and i == 0: pos[0] = s.global_position
			elif e and i == p_last: pos[-1] = e.global_position
			continue
		
		var velocity = (pos[i] - old_pos[i]) * damping
		old_pos[i] = pos[i]
		pos[i] = pos[i] + velocity + gravity * delta_sq
		
	# 2. Constraint Iterations
	# Running these multiple times forcefully creates an inelastic string
	for iteration in range(stiffness_iterations):
		
		# Distance snapping loop
		for i in range(p_last):
			var p1 = pos[i]
			var p2 = pos[i + 1]
			var diff = p2 - p1
			var dist = diff.length()
			if dist > 0.0001:
				var offset = (dist - segment_length) * 0.5
				var adjustment = (diff / dist) * offset
				
				var weight1 = 0.5
				var weight2 = 0.5
				if s and i == 0: weight1 = 0.0
				if e and i + 1 == p_last: weight2 = 0.0
					
				pos[i] += adjustment * weight1
				pos[i + 1] -= adjustment * weight2

		# Force attachments stay pinned (as constraints might yank them out)
		if s: pos[0] = s.global_position
		if e: pos[-1] = e.global_position

	# 3. Environment Handling (Runs ONCE per frame)
	for i in range(p_size):
		if (s and i == 0) or (e and i == p_last): continue
		
		var contact_normal = Vector3.ZERO
		var is_colliding = false
		
		# Continuous Collision (Swept raycast catching fast movements through geometry)
		query.from = old_pos[i]
		query.to = pos[i]
		var hit = space_state.intersect_ray(query)
		
		if hit:
			var n = hit.normal
			pos[i] = hit.position + n * thickness
			contact_normal = hit.normal
			is_colliding = true
		else:
			# Proximity Collision (Raycast downwards to create a floor buffer and stop slow sinking)
			var up_pos = pos[i]
			up_pos.y += half_thickness
			var down_pos = pos[i]
			down_pos.y -= thickness
			
			down_query.from = up_pos
			down_query.to = down_pos
			var down_hit = space_state.intersect_ray(down_query)
			
			if down_hit:
				var n = down_hit.normal
				pos[i] = down_hit.position + n * thickness
				contact_normal = down_hit.normal
				is_colliding = true

		if is_colliding:
			var vel = pos[i] - old_pos[i]
			var check_bounce = vel.dot(contact_normal)
			if check_bounce < 0:
				vel -= contact_normal * check_bounce
			vel *= (1.0 - friction)
			old_pos[i] = pos[i] - vel

	# 4. Self-Collision (Optional, runs ONCE per frame AFTER environment so it doesn't push into floors)
	if enable_self_collision:
		for iteration in range(2): # Give it 2 quick passes to form solid knots
			for i in range(p_size):
				# Start at i + 2 to skip adjacent nodes
				for j in range(i + 2, p_size):
					var p1 = pos[i]
					var p2 = pos[j]
					var diff = p2 - p1
					var dist_sq = diff.length_squared()
					
					if dist_sq < min_dist_sq and dist_sq > 0.0001:
						var dist = sqrt(dist_sq)
						var offset = (min_dist - dist) * 0.5
						# Push them apart
						var adjustment = (diff / dist) * offset
						
						var weight1 = 0.5
						var weight2 = 0.5
						if s and i == 0: weight1 = 0.0
						if e and j == p_last: weight2 = 0.0
						
						pos[i] -= adjustment * weight1
						pos[j] += adjustment * weight2
