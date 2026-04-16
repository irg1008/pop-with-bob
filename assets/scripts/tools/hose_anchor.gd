class_name HoseAnchor extends Node


@export var attachment_start: Node3D
@export var rope: Rope3D


var player: PlayerController


func _ready() -> void:
	rope.anchor_distanced.connect(_on_anchor_distanced)

	if attachment_start:
		rope.attachment_start = attachment_start.get_path()

	set_player_as_anchor_end.call_deferred()


func set_player_as_anchor_end() -> void:
	player = PlayerController.get_player_node(get_tree())
	rope.attachment_end = player.get_path()


func _on_anchor_distanced(offset: Vector3) -> void:
	if not player:
		return

	if abs(offset.x) > 0.5:
		rope.attachment_end = ""
