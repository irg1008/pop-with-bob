class_name UserInterface extends CanvasLayer


@export_group("References")
@export var player: PlayerController
@export var progress_manager: ProgressManager


@onready var coins_label: Label = $CurrenciesContainer/BoxContainer/CoinsLabel
@onready var ammo_label: Label = $CurrenciesContainer/BoxContainer/AmmoLabel
@onready var water_label: Label = $CurrenciesContainer/BoxContainer/WaterLabel

@onready var interaction_hint: RichTextLabel = $InteractionContainer/InteractionHint

@onready var store_panel: StorePanel = $StorePanel
@onready var pause_panel: Control = $PausePanel


func _ready() -> void:
	interaction_hint.text = ""
	store_panel.hide()
	pause_panel.hide()

	handle_progress_changes()
	handle_player_changes()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("cancel"):
			return

	if store_panel.visible:
			close_ui_panel(store_panel)
	elif pause_panel.visible:
			close_pause()
	else:
			open_pause()


func handle_player_changes() -> void:
	player.weapon_controller.ammo_changed.connect(_on_weapon_controller_ammo_changed)

	player.interaction_entered.connect(_on_player_interaction_entered)
	player.interaction_exited.connect(_on_player_interaction_exited)
	player.interaction_actioned.connect(_on_player_interaction_actioned)


func handle_progress_changes() -> void:
	progress_manager.coins_changed.connect(_on_coins_changed)


func _on_player_interaction_entered(interaction: InteractableComponent) -> void:
	if interaction and interaction.actionable:
		interaction_hint.text = "Press [E] to interact"
	else:
		interaction_hint.text = ""


func _on_player_interaction_exited(_interaction: InteractableComponent) -> void:
	interaction_hint.text = ""


func _on_player_interaction_actioned(interaction: InteractableComponent) -> void:
	if interaction.owner is Store:
		show_ui_panel(store_panel)


func _on_coins_changed(coins: float) -> void:
	coins_label.text = "Coins: %d" % coins


func _on_weapon_controller_ammo_changed(ammo: int) -> void:
	ammo_label.text = "Ammo: %d" % ammo


func _on_water_changed(water: float) -> void:
	water_label.text = "Water: %d" % water


func show_ui_panel(panel: Control) -> void:
	panel.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Managers.game_manager.lock_input()


func close_ui_panel(panel: Control) -> void:
	panel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Managers.game_manager.unlock_input()


func open_pause() -> void:
	get_tree().paused = true
	show_ui_panel(pause_panel)


func close_pause() -> void:
	get_tree().paused = false
	close_ui_panel(pause_panel)
