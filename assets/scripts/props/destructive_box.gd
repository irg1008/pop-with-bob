extends StaticBody3D


func _on_health_component_died() -> void:
	print("Destructive box destroyed")
	queue_free()
