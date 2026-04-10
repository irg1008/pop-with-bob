@abstract
class_name StoreItem extends Resource


@export var name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var price: float
enum Currency {COINS, WATER}
@export var currency: Currency
@export var max_available: int = 0


var available: int = 0


func format_text() -> String:
  return "{name} - {price} {currency}".format({
      "name": name,
      "price": price,
      "currency": get_currency_label(currency)
    })


func on_purchased() -> void:
  pass


func can_purchase() -> bool:
  return true


static func get_currency_label(curr: Currency) -> String:
  match curr:
    Currency.COINS:
      return "Coins"
    Currency.WATER:
      return "Water"

  return "Unknown"
