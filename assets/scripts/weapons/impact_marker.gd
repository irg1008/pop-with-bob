class_name ImpactMarker extends Node


static func spawn_impact_marker(tree: SceneTree, position: Vector3) -> void:
		var marker: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(0.1, 0.1, 0.1)
		marker.mesh = box

		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color.RED
		marker.set_surface_override_material(0, material)

		tree.current_scene.add_child(marker)
		marker.global_position = position

		tree.create_timer(5.0).timeout.connect(marker.queue_free)