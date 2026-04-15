class_name HoseAnchor extends Node


@export var hose: Hose3D


func _ready() -> void:
	set_player_as_anchor_end.call_deferred()


func set_player_as_anchor_end() -> void:
	var player: PlayerController = PlayerController.get_player_node(get_tree())
	hose.attachment_end = player.get_path()
