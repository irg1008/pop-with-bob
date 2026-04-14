class_name SoapComponent extends Node


@export_category("References")
@export var character_bubble_emitter: CharacterBubbleEmitter
@export var bubble_emitter: BubbleEmitter
@export var water_component: WaterComponent

@export_category("Soaps")
@export var initial_max_soaps: int = 4
@export var initial_soaps: Array[StoreSoap] = []


var soaps: Array[StoreSoap] = []: set = set_soaps
var max_soaps: int


func _ready() -> void:
	set_soaps(initial_soaps)

	bubble_emitter.bubble_created.connect(_on_bubble_created)
	water_component.water_depleted.connect(_on_water_depleted)


func can_add_soap() -> bool:
	return soaps.size() < max_soaps


func _on_bubble_created(bubble: Bubble) -> void:
	use_soap(bubble)


func _on_water_depleted() -> void:
	for soap: StoreSoap in soaps:
		soap.apply_water_component_depleted_mods(character_bubble_emitter, water_component)


func init_soap(soap: StoreSoap) -> StoreSoap:
	soap.init()
	soap.soap_depleted.connect(_on_soap_depleted)
	soap.soap_ammo_change.connect(_on_soap_ammo_changed)

	soap.apply_soap_component_mods(self)

	if character_bubble_emitter:
		soap.apply_character_mods(character_bubble_emitter)

	if bubble_emitter:
		soap.apply_emitter_data_mods(bubble_emitter.emitter_data)
		soap.apply_bubble_data_mods(bubble_emitter.emitter_data.bubble)

	if water_component:
		soap.apply_water_component_mods(water_component)

	return soap


func _on_soap_depleted(soap: StoreSoap) -> void:
	soaps.erase(soap)


func _on_soap_ammo_changed(ammo: int) -> void:
	Managers.weapon_manager.add_currrent_weapon_ammo(ammo)


func set_soaps(new_soaps: Array[StoreSoap]) -> void:
	max_soaps = initial_max_soaps
	soaps.assign(new_soaps.map(init_soap))


func use_soap(bubble: Bubble) -> void:
	for i: int in range(soaps.size()):
		var prev_soap: StoreSoap = soaps[i - 1] if i > 0 else null
		var soap: StoreSoap = soaps[i]
		soap.use_soap(bubble, prev_soap)
