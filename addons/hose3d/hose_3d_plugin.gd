@tool
extends EditorPlugin

func _enter_tree() -> void:
	# Register the Hose3D node. We'll use the default Godot icon if a custom one isn't provided.
	add_custom_type("Hose3D", "Path3D", preload("res://addons/hose3d/hose_3d.gd"), null)

func _exit_tree() -> void:
	# Clean up when the plugin is disabled
	remove_custom_type("Hose3D")
