class_name ProgressManager extends Node


signal coins_changed(new_coins: float)
signal water_changed(new_water: float)
signal currency_changed()


@export_category("References")
@export var player: PlayerController


const PROGRESS_MANAGER_GROUP: String = "progress_manager"


var current_water: float = 0.0: set = set_water
var current_coins: float = 0.0: set = set_coins


func set_coins(amount: float) -> void:
	current_coins = amount
	coins_changed.emit(current_coins)
	currency_changed.emit()


func set_water(amount: float) -> void:
	current_water = amount
	water_changed.emit(current_water)
	currency_changed.emit()


func _ready() -> void:
	add_to_group(PROGRESS_MANAGER_GROUP)


func add_coins(reward: float) -> void:
	current_coins += reward
	coins_changed.emit(current_coins)


func can_purchase(store_item: StoreItem) -> bool:
	var available_currency: float = 0.0

	match store_item.currency:
		StoreItem.Currency.COINS:
			available_currency = current_coins
		StoreItem.Currency.WATER:
			available_currency = current_water

	return store_item.can_purchase() and available_currency >= store_item.price


func attempt_purchase(store_item: StoreItem) -> void:
	if not can_purchase(store_item):
		return

	match store_item.currency:
		StoreItem.Currency.COINS:
			current_coins -= store_item.price
		StoreItem.Currency.WATER:
			current_water -= store_item.price

	store_item.on_purchased()
