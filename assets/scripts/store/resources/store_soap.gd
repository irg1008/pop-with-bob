class_name StoreSoap extends StoreItem

@export var max_uses: int = 100

@export_category("Modifiers")
## Increase number of slots for soaps in npc
@export var max_soaps_increase: int = 0
## Chance that the next soap will be used
@export var next_soaps_use_chance: float = 1.0
@export_group("Water Usage")
@export var water_usage_mod: float = 1.0
@export var no_water_used_chance: float = 0.0
## Chance to refill full water when water runs out
@export var refill_water_on_empty_chance: float = 0.0
@export var destroy_soap_instead_chance: float = 0.0
@export_group("Bubble Settings")
@export var size_mod: float = 1.0
@export var spawn_rate_mod: float = 1.0
@export var reward_increase: float = 0.0
@export var reward_multiplier: float = 1.0
@export var gold_chance_mod: float = 1.0
@export var gold_reward_increase: float = 0.0
@export var gold_reward_multiplier: float = 1.0
@export var bubble_pop_chance_mod: float = 1.0
@export var max_bubbles_increase: int = 0
@export var autopop_chance: float = 0.0
@export var autopop_speed_mod: float = 1.0
@export_group("Health")
@export var health_regen_chance: float = 1.0
@export var health_regen_amount: float = 0.0
@export var health_loss_chance: float = 1.0
@export var health_loss_amount: float = 0.0
@export_group("Ammo")
@export var ammo_recover_chance: float = 0.0
@export var ammo_recover_amount: float = 0.0
@export var ammo_loss_chance: float = 0.0
@export var ammo_loss_amount: float = 0.0
@export_group("Other")
## Chance the npc will attack other npcs instead of the player
@export var crazy_chance: float = 0.0
## Chance the npc will stop generating bubbles and just stand there
@export var sindicated_chance: float = 0.0


func apply_character_bubble_emitter_mods(character_bubble_emitter: CharacterBubbleEmitter) -> CharacterBubbleEmitter:
	print("Applying character bubble emitter mods from soap: ", name)
	return character_bubble_emitter


func apply_bubble_emitter_mods(bubble_emitter: BubbleEmitterData) -> BubbleEmitterData:
	print("Applying bubble emitter mods from soap: ", name)
	return bubble_emitter


func apply_pop_mods(_prev_soap: StoreSoap) -> void:
	print("Applying pop mods from soap: ", name)
	return