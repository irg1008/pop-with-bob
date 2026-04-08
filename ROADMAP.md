# Pop with Bob - Full Development Roadmap

## 1) Vision and Core Pillars

Pop with Bob is an incremental first-person bubble-popping game.
Main loop:
1. Pop bubbles to earn money.
2. Spend money in a thematic set store.
3. Improve your power, economy, and automation.
4. Unlock the next movie set door.
5. Trigger a global reset (restart from the beginning) to accelerate future runs.

Core pillars:
- Fast tactile popping and shooting.
- Clear short-term goals (next purchase, next door).
- Strong long-term progression (global reset and meta progression).
- Multiple viable paths to complete all sets.
- Stylized movie-set fantasy that supports scope-friendly production.


## 2) Current Project Baseline (What You Already Have)

Already implemented in project scripts and scenes:
- Player movement and camera systems.
- Weapon controller, weapon resources, projectile and hitscan flow.
- Health component and damage application.
- Bubble entities, bubble emitters, and reward values in data resources.
- Weapon manager and switching structure.
- Enemy and pickup foundations.

Main gap now:
- Economy, progression, store loop, reset loop, persistence, and content pipeline are not fully connected as one coherent game progression system.


## 3) Final Game Structure (Target)

### 3.1 Sets, Characters, Weapons

You have 8 characters and 6 sets.
Planned mapping:
- Desert set: cactus, shotgun.
- Ocean floor set with caustics: fish, trident.
- Magic pond set: spiky blob + mushroom, magic wand.
- Flying castle set: flying demon + flying king, bow and arrows.
- Feudal Kyoto street set: ninja, bamboo cerbatana.
- Volcanic landscape set: orc, axe.

### 3.2 World Layout

- Hub corridor that connects all set doors.
- Each door requires a progression threshold.
- Weapons are swapped by entering or activating each set loadout.
- One thematic store per set (same merchant logic, set-specific skin/dialogue/prices/upgrades).


## 4) Progression and Economy Rules (Incremental Design)

## 4.1 Currencies

Use 2-layer currency to avoid dead progression:
1. Cash (run currency spent during the current run).
2. Film Reels (global reset currency used for permanent meta progression).

## 4.2 Upgrade Categories Per Set

Keep identical category structure in all sets for production speed and balance consistency:
1. Firepower:
- damage
- fire rate
- projectile speed or hit quality
- spread/accuracy handling

2. Economy:
- bubble value
- gold bubble probability
- rare bubble multipliers

3. Automation:
- passive helper emitters
- auto-pop chance
- support entities that generate money over time

4. Utility:
- ammo sustain/reload quality
- movement and pickup quality of life
- interaction speed

## 4.3 Door Unlock Rule (Multiple Paths)

Every set has a door score that can be achieved through different builds.

Door score example:
- DoorScore = FirepowerScore + EconomyScore + AutomationScore + ChallengeScore

Door opens when:
- DoorScore >= SetThreshold

This ensures players can progress through different playstyles instead of one forced route.

## 4.4 Cost and Reward Curves (Starting Formula)

Use these as tuning defaults:
- UpgradeCostNext = UpgradeCostCurrent * r, where r is between 1.12 and 1.22
- IncomePerSecond = PopRate * BubbleValue * Multipliers

Global reset reward starter formula:
- FilmReelGain = floor((TotalLifetimeCashThisRun / G)^0.35)

G is a balancing constant. Increase it if reset progression is too fast.


## 5) Reset System Design (What Resets Keep)

## 5.1 Global Reset (Only Reset Type)

Purpose:
- Restart the full run from the beginning and gain permanent meta power.

Global Reset loses:
- Cash.
- Run upgrades and temporary run modifiers.
- Run door progression state.
- Temporary spawned helpers and run-only world state.

Global Reset keeps:
- Film Reels.
- Meta tree unlocks and permanent global bonuses.
- Cosmetics and profile milestones.
- Quality-of-life global unlocks.

Never remove core movement/shoot feel to avoid frustration.


## 6) Difficulty and Fun Balancing Framework

## 6.1 Time Targets

Set first-clear target times:
- Set 1: 20 to 30 minutes.
- Set 2: 30 to 45 minutes.
- Set 3: 45 to 60 minutes.
- Set 4 to 6: add around 15 to 20 minutes each.

## 6.2 Engagement Cadence

- Meaningful purchase every 2 to 4 minutes.
- One clear short-term objective always visible.
- If player waits more than 8 minutes for next meaningful purchase, rebalance.

## 6.3 Build Diversity Checks

At each balancing pass, compare:
- Firepower path progression time.
- Economy path progression time.
- Automation path progression time.

Target:
- All paths within about plus/minus 15% time to next door.

## 6.4 Basic Telemetry You Should Track

- Pops per minute.
- Currency per minute.
- Time to first upgrade in set.
- Time to door unlock.
- Reset frequency.
- Most and least purchased upgrades.

Use this data before making tuning decisions.


## 7) Production Roadmap in Order

## Phase 0 - Design Lock (2 to 3 days)

Deliverables:
- Final currency definitions.
- Final reset rules.
- Door unlock score model.
- Upgrade category list per set.
- Data sheet template for tuning.

Do not build more content before this is written and frozen.

## Phase 1 - Economy Core (Week 1)

Deliverables:
- Economy manager singleton with:
  - add/spend methods
  - transaction events
  - run and global currency containers
- Bubble reward wiring into economy manager.
- Basic store transaction validation.

Success criteria:
- Bubble pops change currency reliably.
- Store purchase and affordability checks are stable.

## Phase 2 - Persistence and Autosave (Week 1)

Deliverables:
- Save schema version 1.
- Manual save/load.
- Autosave timer and safe-on-exit save.
- Corruption-safe fallback and schema migration hook.

Success criteria:
- Restarting game restores economy, upgrades, door states, and resets.

## Phase 3 - Door and Corridor Progression (Week 1)

Deliverables:
- Data-driven door requirement system.
- Door UI feedback (what is missing to unlock).
- Transition flow from corridor to set and back.

Success criteria:
- Door unlock state updates immediately after meeting threshold.

## Phase 4 - Set Template Framework (Week 2)

Deliverables:
- Reusable SetController and SetData resources.
- Shared set shop logic (same merchant backend).
- Shared upgrade definitions and purchase flow.

Success criteria:
- New set can be created mainly by data and assets, not copy-paste logic.

## Phase 5 - Desert Vertical Slice (Week 2 to 3)

Deliverables:
- Desert map pass.
- Cactus behavior integration.
- Shotgun full balancing.
- Desert store with all upgrade categories.
- Desert full run loop and first door completion.

Success criteria:
- Complete playable set loop from start to global reset and back to door unlock.

## Phase 6 - Multi-Path Progression (Week 4)

Deliverables:
- Path scoring and balancing adjustments.
- Distinct early/mid advantages for each path.
- UI clarity for path identity.

Success criteria:
- Players can finish through at least two very different builds.

## Phase 7 - Remaining Sets Through Template (Week 5 to 8)

Deliverables:
- Ocean set + fish + trident.
- Magic pond set + spiky blob/mushroom + wand.
- Flying castle set + demon/king + bow.
- Feudal Kyoto set + ninja + cerbatana.
- Volcanic set + orc + axe.

Success criteria:
- All six sets playable with thematic identity and progression coherence.

## Phase 8 - Global Reset Endgame Layer (Week 9)

Deliverables:
- Film Reel global reset progression system.
- Meta progression tree.
- Final completion conditions for all sets.
- Endgame challenge targets.

Success criteria:
- Long-term replay loop works beyond first full completion.

## Phase 9 - Polish and Shipping Readiness (Week 10+)

Deliverables:
- Audio layering and stingers per set.
- Performance optimization and bug fixes.
- UI readability and onboarding tutorialization.
- Accessibility and settings pass.

Success criteria:
- Stable build with understandable progression and satisfying pacing.


## 8) Beginner-First Godot Fundamentals You Must Add to Scope

These are mandatory foundation topics for a complete game, especially for new Godot developers.

## 8.1 Saving and Loading

Use these docs:
- Saving games tutorial:
  https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
- FileAccess:
  https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
- Data paths (user://):
  https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
- JSON:
  https://docs.godotengine.org/en/stable/classes/class_json.html
- ConfigFile:
  https://docs.godotengine.org/en/stable/classes/class_configfile.html

What to do:
- Define one save root object with version field.
- Save only data, never scene node references.
- Add migration step for old save versions.

## 8.2 Autosaving

Use these docs/concepts:
- Timer:
  https://docs.godotengine.org/en/stable/classes/class_timer.html
- SceneTree notifications and quit flow:
  https://docs.godotengine.org/en/stable/classes/class_mainloop.html

What to do:
- Autosave every 30 to 90 seconds.
- Save on important events: purchase, unlock, and global reset.
- Save when game is closing.
- Keep backup save slot to recover from corruption.

## 8.3 Global Managers and State Ownership

Use this doc:
- Singletons (Autoload):
  https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

What to do:
- Create autoloads for EconomyManager, SaveManager, ProgressionManager, AudioManager.
- Keep responsibilities separated to avoid one giant manager script.

## 8.4 Resource-Driven Data Design

Use these docs:
- Resources:
  https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- ResourceSaver:
  https://docs.godotengine.org/en/stable/classes/class_resourcesaver.html
- ResourceLoader:
  https://docs.godotengine.org/en/stable/classes/class_resourceloader.html

What to do:
- Store weapon, set, upgrade, and door parameters as resources.
- Tune values through inspector and data assets, not hardcoded constants.

## 8.5 Signals and Decoupled UI

Use this doc:
- Signals step by step:
  https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html

What to do:
- Economy emits currency_changed.
- Progression emits door_unlocked.
- UI listens to signals only; avoid direct hard references where possible.

## 8.6 Input and Rebinding

Use this doc:
- Input examples and InputMap:
  https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html

What to do:
- Keep all gameplay actions in InputMap.
- Add keybinding settings later in polish phase.

## 8.7 Audio System Basics

Use these docs:
- Audio buses:
  https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html
- Audio streams:
  https://docs.godotengine.org/en/stable/tutorials/audio/audio_streams.html

What to do:
- Separate buses: Master, Music, SFX, UI.
- Add per-set music loops plus intensity layers.
- Add popup, unlock, purchase, and prestige audio feedback.

## 8.8 Export and Distribution Basics

Use docs:
- Exporting projects:
  https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html

What to do:
- Prepare export presets early.
- Test save path behavior in exported builds, not only editor.


## 9) Art, Level, and Scope Strategy for Solo Execution

Because you are not an art specialist, use strict production constraints:

1. Per set asset budget:
- 1 hero landmark prop.
- 3 medium props.
- 5 filler props.
- 1 lighting profile.
- 1 fog/atmosphere profile.

2. Reuse and variation strategy:
- Reuse modular props with material swaps.
- Reuse one shop NPC logic and animate theme via skins and voice lines.
- Keep one corridor architecture and vary signage, decals, and lighting.

3. Set completion quality bar:
- Gameplay readability first.
- Theme identity second.
- Visual polish third.


## 10) Concrete First 14-Day Plan

Day 1 to 2:
- Finalize design lock document and formulas.
- Define save schema and progression data model.

Day 3 to 5:
- Implement EconomyManager and SaveManager autoloads.
- Wire bubble reward to cash.
- Add manual save/load test scene button.

Day 6 to 7:
- Add autosave timer + save-on-exit + backup slot.
- Implement door requirement evaluator.

Day 8 to 10:
- Build SetTemplate resources and generic set controller.
- Implement shared store flow and upgrade purchasing.

Day 11 to 14:
- Build Desert vertical slice end-to-end.
- Test first full loop: start -> upgrade -> global reset -> unlock door again faster.
- Do first balance pass using telemetry metrics.


## 11) Definition of Done for Your First Playable Milestone

Milestone is done when:
- One complete set loop works reliably.
- Save/load/autosave survive restarts.
- At least two progression paths are viable to open the first door.
- Global reset gives a meaningful acceleration on second run.
- Player always has visible next objective.


## 12) Future Extensions (After Core Completion)

- Daily or weekly challenge boards.
- Limited-time set modifiers.
- Cosmetic progression track.
- Optional narrative snippets between doors.
- Achievements tied to different path completions.


## 13) Immediate Next Action

Start by implementing Phase 1 and Phase 2 together:
- Economy + Save systems first.

Reason:
- Every future feature (stores, upgrades, resets, doors, balancing) depends on reliable persistent progression.


## 13.1 Implementation Compass: Node vs Resource vs Save Data

Use this as a fast decision guide when building features.

### A) Use Node when the thing has runtime behavior

Use Node or Node3D for:
- Active gameplay objects (player, bubble, enemy, projectile, doors, UI controllers).
- Objects that need process functions, signals, collisions, scene hierarchy, or transforms.

Node lifetime:
- Exists while scene is running.
- Destroyed when scene changes unless intentionally preserved.

### B) Use Resource when the thing is reusable design data

Use Resource for:
- Weapon base stats.
- Upgrade definitions and formulas.
- Set configuration.
- Door requirement templates.

Important Resource behavior:
1. Resources are references.
2. If multiple nodes reference the same Resource object, editing it at runtime affects all those users.
3. Runtime edits are not automatically saved to disk.

Practical rule:
- Treat Resources as static design assets loaded from res://.
- Do not store player progression directly by mutating shared design Resources.

### C) Use Save Data for player progression

Save data should contain only player state, for example:
- Currency values.
- Purchased upgrades.
- Unlocked doors.
- Reset/prestige counters.
- Active set and profile progress.

Persistence rule:
- If data must survive game restart, it must be written to user:// through a save system.

### D) Quick decision table

| You are storing... | Use | Why |
|---|---|---|
| Bubble actor in world | Node3D scene instance | Runtime behavior + transform + lifetime |
| Weapon blueprint stats | Resource | Reusable configuration |
| Store catalog entries | Resource | Data-driven content tuning |
| Player money and unlocks | Save data file | Must persist across sessions |
| Current run temporary buffs | Manager runtime state | Session-only values |

### E) Common mistakes to avoid

1. Mutating shared Resource assets to represent progression.
- Why bad: can leak changes to all users in current session and create confusing editor/runtime behavior.

2. Saving gameplay state to res://.
- Why bad: not writable in exported games.
- Use user:// for save files.

3. Mixing static config and dynamic progress in one structure.
- Why bad: hard to migrate versions and balance safely.

### F) Safe pattern for your game

1. Keep design data in Resource assets (weapons, upgrades, sets, doors).
2. Keep player progress in SaveData dictionaries or typed save resources under user://.
3. At runtime, combine them:
- final_stat = base_resource_stat + purchased_upgrades + prestige_modifiers

### G) References (Godot docs)

- Resources:
  https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- Resource class:
  https://docs.godotengine.org/en/stable/classes/class_resource.html
- ResourceSaver:
  https://docs.godotengine.org/en/stable/classes/class_resourcesaver.html
- Saving games:
  https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
- Data paths (user://):
  https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html


## 14) Ticket-Based Task Board (You Implement, I Coach)

Use this as your working backlog. You code each ticket, and I help with formulas, architecture, balancing, art direction, and review.

Ticket fields:
- Priority: P0 critical, P1 important, P2 nice to have.
- Size: S (up to half day), M (1 day), L (2 to 3 days).
- Dependencies: Ticket IDs that should be done first.

### 14.1 Sprint 0: Foundation and Safety (Start Here)

| ID | Title | Priority | Size | Dependencies | Done criteria |
|---|---|---|---|---|---|
| PWB-001 | Write one-page design lock | P0 | S | None | Currencies, reset rules, and door logic frozen in one document |
| PWB-002 | Define save data schema v1 | P0 | S | PWB-001 | JSON schema includes version, economy, upgrades, doors, reset data |
| PWB-003 | Create EconomyManager contract | P0 | S | PWB-001 | Clear API list for add, spend, affordability, and signals |
| PWB-004 | Create SaveManager contract | P0 | S | PWB-002 | Clear API list for save, load, autosave, migration |
| PWB-005 | Add economy autoload registration | P0 | S | PWB-003 | Economy autoload available globally and initialized cleanly |
| PWB-006 | Add save autoload registration | P0 | S | PWB-004 | Save autoload available globally and initialized cleanly |
| PWB-007 | Manual save and load flow | P0 | M | PWB-005, PWB-006 | You can save, restart, load, and restore expected state |
| PWB-008 | Autosave timer and save-on-exit | P0 | M | PWB-007 | Autosave runs on interval and on quit without corruption |
| PWB-009 | Backup save slot failover | P1 | M | PWB-008 | If primary file is invalid, backup file restores progress |

### 14.2 Sprint 1: Economy Wiring and Progression Doors

| ID | Title | Priority | Size | Dependencies | Done criteria |
|---|---|---|---|---|---|
| PWB-010 | Wire bubble pop reward to economy | P0 | M | PWB-005 | Every popped bubble changes currency deterministically |
| PWB-011 | Add transaction event logging | P1 | S | PWB-010 | Purchases and rewards emit auditable events |
| PWB-012 | Create door requirement data resource | P0 | M | PWB-001 | Door conditions are defined in data, not hardcoded |
| PWB-013 | Build door evaluator service | P0 | M | PWB-012 | Evaluator returns locked or unlocked and missing criteria |
| PWB-014 | Corridor door UI feedback | P1 | M | PWB-013 | Player sees exactly what is needed for each door |
| PWB-015 | Persist door states in save | P0 | S | PWB-007, PWB-013 | Door unlocks survive restart |

### 14.3 Sprint 2: Set Template and Store Core

| ID | Title | Priority | Size | Dependencies | Done criteria |
|---|---|---|---|---|---|
| PWB-016 | Create SetData resource model | P0 | M | PWB-001 | Set has weapon, shop, economy modifiers, and global reset hooks |
| PWB-017 | Create UpgradeData resource model | P0 | M | PWB-001 | Upgrade has cost curve, cap, effect type, and tags |
| PWB-018 | Build generic SetController flow | P0 | L | PWB-016 | Enter, run, and exit set through one reusable controller |
| PWB-019 | Build generic store purchase pipeline | P0 | M | PWB-017, PWB-010 | Buy flow validates affordability, applies effect, saves state |
| PWB-020 | Add upgrade UI binding by data | P1 | M | PWB-019 | Store UI auto-builds from UpgradeData list |
| PWB-021 | Persist per-set upgrades | P0 | M | PWB-019, PWB-007 | Upgrades restore correctly after reload |

### 14.4 Sprint 3: Desert Vertical Slice

| ID | Title | Priority | Size | Dependencies | Done criteria |
|---|---|---|---|---|---|
| PWB-022 | Desert set blockout pass | P0 | M | PWB-018 | Playable traversal and readable combat space |
| PWB-023 | Desert themed shop skin pass | P1 | S | PWB-019 | Same store logic, desert visual identity |
| PWB-024 | Shotgun tuning pass for set 1 | P0 | M | Existing weapon flow | Time-to-pop and feel hit target pacing |
| PWB-025 | Desert path scoring values | P0 | S | PWB-013 | Firepower, economy, automation all viable for first door |
| PWB-026 | Desert first-door unlock test | P0 | S | PWB-022, PWB-025 | First clear within target 20 to 30 minutes |

### 14.5 Sprint 4: Global Reset and Multi-Path Balance

| ID | Title | Priority | Size | Dependencies | Done criteria |
|---|---|---|---|---|---|
| PWB-027 | Implement global reset action flow | P0 | M | PWB-021 | Reset restarts full run and preserves only global permanent data |
| PWB-028 | Implement global reset gain formula | P0 | S | PWB-027 | Film Reel gain uses formula and is tunable by constants |
| PWB-029 | Apply starter global meta perks | P1 | M | PWB-028 | Starter meta perks give permanent global acceleration |
| PWB-030 | Add global reset confirmation and preview UI | P1 | S | PWB-027 | Player sees what is lost and gained before confirming |
| PWB-031 | Multi-path parity balancing pass | P0 | M | PWB-026, PWB-029 | Path completion times within about plus/minus 15 percent |

### 14.6 Sprint 5+: Replicate Across Remaining Sets

| ID | Title | Priority | Size | Dependencies | Done criteria |
|---|---|---|---|---|---|
| PWB-032 | Ocean set implementation | P0 | L | PWB-018, PWB-031 | Full set loop playable with trident identity |
| PWB-033 | Magic pond set implementation | P0 | L | PWB-018, PWB-031 | Full set loop playable with wand identity |
| PWB-034 | Flying castle set implementation | P0 | L | PWB-018, PWB-031 | Full set loop playable with bow identity |
| PWB-035 | Kyoto set implementation | P0 | L | PWB-018, PWB-031 | Full set loop playable with cerbatana identity |
| PWB-036 | Volcanic set implementation | P0 | L | PWB-018, PWB-031 | Full set loop playable with axe identity |

### 14.7 Endgame and Polish Tickets

| ID | Title | Priority | Size | Dependencies | Done criteria |
|---|---|---|---|---|---|
| PWB-037 | Tune global reset economy for late game | P0 | M | PWB-032 to PWB-036 | Global reset pacing remains stable through all sets |
| PWB-038 | Expand endgame meta progression tree | P1 | M | PWB-037 | Endgame global upgrades affect all sets and remain balanced |
| PWB-039 | Add telemetry debug dashboard | P1 | M | PWB-010 | Core balancing metrics visible during playtests |
| PWB-040 | Add set music layering logic | P1 | M | Audio setup | Music responds to pacing and events |
| PWB-041 | Add onboarding and objective prompts | P1 | M | PWB-014 | New players understand first 10 minutes clearly |
| PWB-042 | Export build stability pass | P0 | M | PWB-007 onward | Saves, doors, and progression stable in exported build |

### 14.8 First Ticket Queue You Should Start Today

Start in this exact order:
1. PWB-001
2. PWB-002
3. PWB-003
4. PWB-004
5. PWB-005
6. PWB-006
7. PWB-007
8. PWB-010
9. PWB-012
10. PWB-013

When you finish these 10 tickets, you will have a safe technical base for all future content.

### 14.9 How I Support You Per Ticket (No Full Implementation)

For each ticket, ask me for any of these:
1. Math formulas and balancing constants.
2. Data model review and naming suggestions.
3. Architecture decision tradeoffs.
4. Pseudocode and flowcharts.
5. Playtest interpretation and tuning recommendations.
6. Art direction prompts and asset scope control.

I will only implement full mechanics if you explicitly ask me to do so.
