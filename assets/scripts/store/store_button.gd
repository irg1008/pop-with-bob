class_name StoreButton extends Button


@export var store_item: StoreItem


func _ready() -> void:
	format_text()
	button_down.connect(_on_button_down)

	listen_currency_changes.call_deferred()
	check_disabled.call_deferred()


func format_text() -> void:
	if not store_item:
		return

	text = store_item.format_text()


func listen_currency_changes() -> void:
	if not Managers.progress_manager:
		return

	Managers.progress_manager.currency_changed.connect(check_disabled)


func check_disabled() -> void:
	if not store_item:
		disabled = true
		return

	disabled = not Managers.progress_manager.can_purchase(store_item)


func _on_button_down() -> void:
	if not store_item:
		return

	Managers.progress_manager.attempt_purchase(store_item)
	check_disabled()
