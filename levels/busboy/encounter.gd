class_name BusboyEncounter
extends RefCounted
## Small turn-resolution model inspired by the retained Monsters action flow.
## No MonsterState/party/capture/XP or archived resource dependency.

enum Phase {PLAYER, RESOLVING, VICTORY, DEFEAT}
var phase: Phase = Phase.PLAYER
var health: int = 18
var enemy_health: int = 18
var mana: int = 4
var corruption: int = 0
var turn: int = 0
var guarding: bool = false
var wait: float = 0
var message: String = "The roots gather. Choose a move."

func intent() -> String:
	match turn % 3:
		0: return "Gather roots — no attack"
		1: return "Heavy lash — 7 damage (+ magic stain)"
		_: return "Thorn jab — 3 damage (+ magic stain)"

func choose(action: String) -> bool:
	if phase != Phase.PLAYER: return false
	match action:
		"strike":
			enemy_health = maxi(0, enemy_health - 4)
			message = "Strike: 4 damage."
		"guard":
			guarding = true
			mana = mini(4, mana + 1)
			message = "Guard: reduce the next attack and recover 1 mana."
		"cleanse":
			if mana < 2:
				message = "Not enough mana. Guard to recover it."
				return false
			mana -= 2
			corruption += 1
			enemy_health = maxi(0, enemy_health - 6)
			message = "Cleanse: 6 damage, but magic leaves a stain."
		_: return false
	if enemy_health == 0:
		phase = Phase.VICTORY
		message = "The knot loosens. The clearing can breathe again."
	else:
		phase = Phase.RESOLVING
		wait = 0.6
	return true

func tick(delta: float) -> void:
	if phase != Phase.RESOLVING: return
	wait -= delta
	if wait > 0: return
	var damage: int = 0
	if turn % 3 == 1: damage = 7 + corruption / 2
	elif turn % 3 == 2: damage = 3 + corruption / 2
	if guarding: damage = floori(damage / 2.0)
	health = maxi(0, health - damage)
	message += " Roots gather." if damage == 0 else " The roots deal %d damage." % damage
	guarding = false
	turn += 1
	if health == 0:
		phase = Phase.DEFEAT
		message = "The forest pushes you back. Rest and try again."
	else: phase = Phase.PLAYER
