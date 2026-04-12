class_name StoreSoap extends StoreItem


signal soap_depleted(soap: StoreSoap)


@export var max_uses: int = 100

@export_category("Modifiers")
@export_group("Soaps")
## Increase number of slots for soaps in npc
@export var max_soaps_increase: int = 0
## Chance that the next soap will be used
@export var next_soap_use_chance: float = 1.0
## Chance the soap will be used on bubble emission
@export var soap_use_chance: float = 1.0
@export_group("Water Usage") # TODO
@export var water_usage_mod: float = 1.0
## Chance of not using water on bubble emission
@export var no_water_used_chance: float = 0.0
## Chance to refill full water when water runs out
@export var refill_water_on_empty_chance: float = 0.0
@export var destroy_soap_instead_chance: float = 0.0
@export_group("Bubble")
@export var size_mod: float = 1.0
@export var inflate_speed_mod: float = 1.0
@export var gravity_increase: float = 0.0
@export var reward_increase: int = 0
@export var reward_multiplier: float = 1.0
@export var mute_pop_sound_chance: float = 0.0
@export_range(0, 100, 1, "suffix:%") var gold_probability_increase: int = 0
@export var gold_probability_mod: float = 1.0
@export var gold_reward_increase: int = 0
@export var gold_reward_multiplier: float = 1.0
## Chance the bubble won't explode on collision
@export var bubble_resist_chance: float = 0.0 # TODO
@export_group("Bubble Emitter")
## Chance the bubble won't pop on collision
@export var max_bubbles_increase: int = 0
@export var spawn_rate_mod: float = 1.0
@export var autopop_chance: float = 0.0
@export var autopop_lifetime: float = 30.0
@export var autopop_lifetime_mod: float = 1.0
@export_group("Health")
@export var health_regen_chance: float = 0.0
@export var health_regen_amount: float = 0.0
@export var health_loss_chance: float = 0.0
@export var health_loss_amount: float = 0.0
@export_group("Ammo") # TODO
@export var ammo_recover_chance: float = 0.0
@export var ammo_recover_amount: float = 0.0
@export var ammo_loss_chance: float = 0.0
@export var ammo_loss_amount: float = 0.0
@export_group("Character Behavior") # TODO
## Chance the npc will attack other npcs instead of the player
@export var crazy_chance: float = 0.0
## Chance the npc will stop generating bubbles and just stand there
@export var sindicated_chance: float = 0.0


var soap_uses: int = 0


func init() -> void:
	soap_uses = max_uses


func is_soap_depleted() -> bool:
	return soap_uses <= 0


# 1. Apply mods to soap_component on soap change (see soap_component.gd)
func apply_soap_component_mods(soap_component: SoapComponent) -> void:
	soap_component.max_soaps += max_soaps_increase


# 2. Apply mods to character_bubble_emitter on soap change (see character_bubble_emitter.gd)
func apply_character_mods(_character: CharacterBubbleEmitter) -> void:
	pass


# 3. Apply mods to bubble emitter on soap change (see bubble_emitter.gd)
func apply_emitter_data_mods(bubble_emitter_data: BubbleEmitterData) -> void:
	bubble_emitter_data.max_current += max_bubbles_increase
	bubble_emitter_data.emit_rate *= spawn_rate_mod

	if randf() < autopop_chance:
		bubble_emitter_data.max_lifetime = autopop_lifetime
		bubble_emitter_data.max_lifetime *= autopop_lifetime_mod


# 4. Apply mods to bubble data on soap change (see bubble_emitter.gd)
func apply_bubble_data_mods(bubble_data: BubbleData) -> void:
	bubble_data.reward += reward_increase
	bubble_data.reward = int(bubble_data.reward * reward_multiplier)

	bubble_data.gold_probability += gold_probability_increase
	bubble_data.gold_probability = int(bubble_data.gold_probability * gold_probability_mod)

	bubble_data.gold_reward += gold_reward_increase
	bubble_data.gold_reward = int(bubble_data.gold_reward * gold_reward_multiplier)


# 5. Apply mods to bubble on bubble emission and use soap (see bubble_emitter.gd)
func use_soap(bubble: Bubble, prev_soap: StoreSoap) -> void:
	if is_soap_depleted():
		return

	bubble.max_scale *= size_mod
	bubble.inflate_speed /= inflate_speed_mod
	bubble.rigid_body.gravity_scale += gravity_increase

	if randf() < mute_pop_sound_chance:
		bubble.mute_pop_sound = true

	# Check if current or previous soap prevents use
	var prev_prevents_use: bool = prev_soap and randf() >= prev_soap.next_soap_use_chance
	var curr_prevents_use: bool = randf() >= soap_use_chance

	if not prev_prevents_use and not curr_prevents_use:
		soap_uses -= 1

	if is_soap_depleted():
		soap_depleted.emit(self)
