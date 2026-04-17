class_name InteractableComponent extends Node


signal actioned()
signal picked_up()
signal dropped()


@export var actionable: bool = true
@export var pickable: bool = false


static var current_picked: InteractableComponent

var player: PlayerController
var current_parent: Node
var is_picked_up: bool = false


func _ready() -> void:
	set_player.call_deferred()
	current_parent = owner.get_parent()


func set_player() -> void:
	player = PlayerController.get_player_node(get_tree())


func action() -> void:
	if current_picked:
		current_picked.drop()

	if is_picked_up:
		drop()
	else:
		pick_up()

	actioned.emit()


func pick_up() -> void:
	if not pickable:
		return

	is_picked_up = true
	current_picked = self

	var parent: Node3D = get_parent()
	parent.reparent(player.camera_pick)

	picked_up.emit()


func drop() -> void:
	if not pickable:
		return

	is_picked_up = false
	current_picked = null

	get_parent().reparent(current_parent)
	dropped.emit()