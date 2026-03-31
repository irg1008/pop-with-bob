@abstract
class_name BaseEnemy extends CharacterBody3D


@export var enemy_groups: Array[String] = []


@abstract func _on_triggered() -> void


func _ready() -> void:
	for group: String in enemy_groups:
		add_to_group(group)
