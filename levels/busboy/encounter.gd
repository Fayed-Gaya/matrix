class_name BusboyEncounter
extends RefCounted
## One transparent turn model, not a party/XP system. Stain is attempt-local.

enum Phase {PLAYER, RESOLVING, VICTORY, DEFEAT}
const MAX_HEALTH: int = 24
const MAX_ROOT: int = 28
const MAX_MANA: int = 4
var phase: Phase = Phase.PLAYER
var health: int = MAX_HEALTH
var enemy_health: int = MAX_ROOT
var mana: int = MAX_MANA
var corruption: int = 0
var turn: int = 0
var guarding: bool = false
var wait: float = 0
var message: String = "The knot tightens around a pale light."
var last_action: String = "Choose your action. The roots' next move is shown above."
var last_reply: String = ""
var effect: String = ""
var effect_time: float = 0

func incoming_damage() -> int:
	var base: int = 0 if turn % 3 == 0 else (7 if turn % 3 == 1 else 3)
	if base == 0: return 0
	var damage: int = base + corruption
	return floori(damage / 2.0) if guarding else damage

func intent() -> String:
	match turn % 3:
		0: return "GATHER · no attack"
		1: return "HEAVY LASH · %d damage" % incoming_damage()
		_: return "THORN JAB · %d damage" % incoming_damage()

func choose(action: String) -> bool:
	if phase != Phase.PLAYER: return false
	match action:
		"strike":
			enemy_health = maxi(0, enemy_health - 4)
			last_action = "Strike — 4 damage. No magic drawn."
		"guard":
			guarding = true
			mana = mini(MAX_MANA, mana + 1)
			corruption = maxi(0, corruption - 1)
			last_action = "Guard — halve the reply, +1 mana, shed 1 stain."
		"cleanse":
			if mana < 2:
				last_action = "Cleanse needs 2 mana."
				last_reply = ""
				message = "Not enough mana. Guard restores 1; no turn was spent."
				return false
			mana -= 2
			corruption += 1
			enemy_health = maxi(0, enemy_health - 7)
			last_action = "Cleanse — 7 damage, -2 mana, +1 stain."
		_: return false
	effect = action
	effect_time = 0.75
	last_reply = ""
	message = "The roots answer…"
	if enemy_health == 0:
		phase = Phase.VICTORY
		message = "The knot releases its hold. Something beneath it is still awake."
	else:
		phase = Phase.RESOLVING
		wait = 0.85
	return true

func tick(delta: float) -> void:
	effect_time = maxf(0, effect_time - delta)
	if phase != Phase.RESOLVING: return
	wait -= delta
	if wait > 0: return
	var damage: int = incoming_damage()
	health = maxi(0, health - damage)
	last_reply = "The roots gather. A moment to act." if damage == 0 else "Roots reply — %d damage%s." % [damage, " (guarded)" if guarding else ""]
	effect = "reply" if damage > 0 else "gather"
	effect_time = 0.6
	guarding = false
	turn += 1
	if health == 0:
		phase = Phase.DEFEAT
		message = "The path can wait. Catch your breath and try again."
	else:
		phase = Phase.PLAYER
		message = "Your turn. Watch the next intention; stain strengthens every attack."
