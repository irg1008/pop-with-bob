class_name InteractableComponent extends Node


signal actioned()
signal picked_up()
signal dropped()


@export var actionable: bool = true
@export var pickable: bool = false


var player: PlayerController
var is_picked_up: bool = false
var current_parent: Node


func _ready() -> void:
	set_player.call_deferred()
	current_parent = owner.get_parent()


func set_player() -> void:
	player = PlayerController.get_player_node(get_tree())


func action() -> void:
	if is_picked_up:
		drop()
	else:
		pick_up()

	actioned.emit()


func pick_up() -> void:
	if not pickable:
		return

	is_picked_up = true
	get_parent().reparent(player.camera)
	picked_up.emit()


func drop() -> void:
	if not pickable:
		return

	is_picked_up = false
	get_parent().reparent(current_parent)
	dropped.emit()