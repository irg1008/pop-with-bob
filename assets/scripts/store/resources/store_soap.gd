class_name StoreSoap extends StoreItem

@export var max_uses: int = 100

@export_category("Modifiers")
@export_group("Soaps")
## Increase number of slots for soaps in npc
@export var max_soaps_increase: int = 0
## Chance that the next soap will be used
@export var next_soaps_use_chance: float = 1.0
@export_group("Water Usage")
@export var water_usage_mod: float = 1.0
## Chance of not using water on bubble emission
@export var no_water_used_chance: float = 0.0
## Chance to refill full water when water runs out
@export var refill_water_on_empty_chance: float = 0.0
@export var destroy_soap_instead_chance: float = 0.0
@export_group("Bubble")
@export var reward_increase: float = 0.0
@export var reward_multiplier: float = 1.0
@export var gold_chance_mod: float = 1.0
@export var gold_reward_increase: float = 0.0
@export var gold_reward_multiplier: float = 1.0
@export var bubble_resist_chance: float = 0.0
@export_group("Bubble Emitter")
## Chance the bubble won't pop on collision
@export var max_bubbles_increase: int = 0
@export var spawn_rate_mod: float = 1.0
@export var autopop_chance: float = 0.0
@export var autopop_speed_mod: float = 1.0
@export var size_mod: float = 1.0
@export var inflate_speed_scale: float = 1.0
@export_group("Health")
@export var health_regen_chance: float = 0.0
@export var health_regen_amount: float = 0.0
@export var health_loss_chance: float = 0.0
@export var health_loss_amount: float = 0.0
@export_group("Ammo")
@export var ammo_recover_chance: float = 0.0
@export var ammo_recover_amount: float = 0.0
@export var ammo_loss_chance: float = 0.0
@export var ammo_loss_amount: float = 0.0
@export_group("Character Behavior")
## Chance the npc will attack other npcs instead of the player
@export var crazy_chance: float = 0.0
## Chance the npc will stop generating bubbles and just stand there
@export var sindicated_chance: float = 0.0


# 1. Apply mods to character on soap change (see character_bubble_emitter.gd)
func apply_character_mods(character: CharacterBubbleEmitter) -> void:
	character.max_soaps += max_soaps_increase


# 2. Apply mods to bubble emitter on soap change (see bubble_emitter.gd)
func apply_emitter_data_mods(bubble_emitter: BubbleEmitterData) -> void:
	pass


# 3. Apply mods to bubble data on soap change (see bubble_emitter.gd)
func apply_bubble_data_mods(bubble_data: BubbleData) -> void:
	# bubble_data.
	pass


# 4. Apply mods to bubble on bubble emission (see bubble_emitter.gd)
func apply_bubble_mods(bubble: Bubble) -> void:
	pass


# 5. Apply mods after bubble pop (see bubble_emitter.gd)
func apply_pop_mods(_prev_soap: StoreSoap) -> void:
	pass