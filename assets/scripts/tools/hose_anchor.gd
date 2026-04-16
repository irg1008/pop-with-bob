class_name HoseAnchor extends Node


@export var attachment_start: Node3D


@onready var hose: RigidHose3D = $RigidHose3D


func _ready() -> void:
	print("HoseAnchor ready with attachment_start: ", attachment_start)
	if attachment_start:
		hose.attachment_start = attachment_start.get_path()

	set_player_as_anchor_end.call_deferred()


func set_player_as_anchor_end() -> void:
	var player: PlayerController = PlayerController.get_player_node(get_tree())
	hose.attachment_end = player.get_path()
