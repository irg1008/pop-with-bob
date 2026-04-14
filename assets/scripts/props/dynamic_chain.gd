@tool
class_name DynamicChain extends Node3D


@export_category("References")
@export var anchor: StaticBody3D:
	set(value):
		anchor = value
		await _regenerate_chain()
@export var link_container: Node3D

@export_category("Chain Settings")
@export_range(2, 50) var link_count: int = 10:
		set(value):
			link_count = value
			await _regenerate_chain()
@export var link_length: float = 0.3:
		set(value):
			link_length = value
			await _regenerate_chain()
@export var link_radius: float = 0.05:
		set(value):
			link_radius = value
			await _regenerate_chain()

@export_group("Joint Settings")
@export var angular_limit_degrees: float = 45.0
@export var twist_limit_degrees: float = 15.0

@export_group("Physics Settings")
@export var link_mass: float = 0.5
@export var link_gravity_scale: float = 1.0
@export var link_damping: float = 0.5

@export_group("Collisions")
@export_flags_2d_physics var collision_layer: int = 1
@export_flags_2d_physics var collision_mask: int = 1

@export_group("Mesh Settings")
@export var link_mesh: Mesh:
	set(value):
		link_mesh = value
		await _regenerate_chain()
@export var mesh_scale: float = 1.0:
	set(value):
		mesh_scale = value
		await _regenerate_chain()
enum ChainType {CHAIN, ROPE}
@export var chain_type: ChainType = ChainType.CHAIN:
	set(value):
		chain_type = value
		await _regenerate_chain()

@export_group("Attachment")
@export var attached_scene: PackedScene


var links: Array[RigidBody3D] = []
var joints: Array[Generic6DOFJoint3D] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		await _generate_chain()


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		await _generate_chain()


func _generate_chain() -> void:
	_clear_chain()

	# Generate links
	for i: int in range(link_count):
		var link: RigidBody3D = _create_link(i)
		link_container.add_child(link)
		links.append(link)
		link.position = Vector3(0, -link_length * i, 0)

	# Wait for links to be in tree
	await get_tree().process_frame

	# Create joints
	for i: int in range(link_count):
		var body_a: Node3D = anchor
		var body_b: RigidBody3D = links[i]

		if i > 0:
			body_a = links[i - 1]

		var joint: Generic6DOFJoint3D = _create_joint(body_a, body_b)
		body_b.add_child(joint)
		joints.append(joint)

	# Attach scene to last link
	if attached_scene and links.size() > 0:
		var last_link: RigidBody3D = links[links.size() - 1]
		var attachment: Node = attached_scene.instantiate()
		link_container.add_child(attachment)

		attachment.global_position = last_link.global_position + Vector3(0, -link_length, 0)

		if attachment is RigidBody3D:
			var joint: Generic6DOFJoint3D = _create_joint(last_link, attachment as RigidBody3D)
			attachment.add_child(joint)


func _regenerate_chain() -> void:
	if not Engine.is_editor_hint():
		return

	_clear_chain()
	await get_tree().process_frame
	await _generate_chain()


func _clear_chain() -> void:
	for link: RigidBody3D in links:
		if is_instance_valid(link):
			link.queue_free()

	links.clear()
	joints.clear()

	for child: Node in link_container.get_children():
		child.queue_free()


func _create_link(index: int) -> RigidBody3D:
	var link: RigidBody3D = RigidBody3D.new()
	link.name = "Link_%d" % index

	# Physics properties
	link.mass = link_mass
	link.gravity_scale = link_gravity_scale
	link.linear_damp = link_damping
	link.angular_damp = link_damping
	link.collision_layer = collision_layer
	link.collision_mask = collision_mask

	# Visual mesh
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()

	if chain_type == ChainType.CHAIN and link_mesh:
		mesh_instance.mesh = link_mesh
	else:
		mesh_instance.mesh = get_default_mesh()

	mesh_instance.scale = Vector3.ONE * mesh_scale
	link.add_child(mesh_instance)

	# Collision shape
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	var capsule_shape: CylinderShape3D = CylinderShape3D.new()
	capsule_shape.height = link_length
	capsule_shape.radius = link_radius
	collision_shape.shape = capsule_shape
	link.add_child(collision_shape)

	return link


func _create_joint(body_a: Node3D, body_b: Node3D) -> Generic6DOFJoint3D:
	var joint: Generic6DOFJoint3D = Generic6DOFJoint3D.new()
	joint.name = "Joint_to_%s" % body_b.name
	joint.position = Vector3(0, link_length * 0.5, 0)

	# Lock X axis (no left/right stretch)
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)

	# Lock Y axis (no up/down stretch)
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)

	# Lock Z axis (no forward/backward stretch)
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)

	# Angular limits (swing range)
	var angular_limit_rad: float = deg_to_rad(angular_limit_degrees)
	var twist_limit_rad: float = deg_to_rad(twist_limit_degrees)

	# X axis swing (pitch)
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -angular_limit_rad)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, angular_limit_rad)

	# Z axis swing (roll)
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -angular_limit_rad)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, angular_limit_rad)

	# Y axis twist
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -twist_limit_rad)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, twist_limit_rad)

	# Set node paths after joint is in tree
	joint.ready.connect(func() -> void:
		joint.node_a = joint.get_path_to(body_a)
		joint.node_b = NodePath("..")
	)

	return joint


func get_default_mesh() -> Mesh:
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.height = link_length
		cylinder.top_radius = link_radius * (0.7 if chain_type == ChainType.CHAIN else 1.0)
		cylinder.bottom_radius = cylinder.top_radius
		return cylinder