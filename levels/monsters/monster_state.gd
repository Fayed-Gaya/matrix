class_name MonsterState
extends RefCounted

var name: String
var level: int
var health: float
var energy: float
var initiative: float = 0
var defending: bool = false
var xp: float = 0
var level_up: float
var catalog: Dictionary
var attacks: Dictionary


func _init(monster_name: String, monster_level: int, definitions: Dictionary, attack_data: Dictionary) -> void:
	name = monster_name
	level = monster_level
	catalog = definitions
	attacks = attack_data
	health = stat("max_health")
	energy = stat("max_energy")
	level_up = level*150


func stat(key: String) -> float:
	return float(catalog[name].stats[key])*level


func element() -> String:
	return catalog[name].stats.element


func abilities(all: bool = true) -> Array[String]:
	var result: Array[String] = []
	for threshold: String in catalog[name].abilities:
		var ability: String = catalog[name].abilities[threshold]
		if level >= int(threshold) and (all or float(attacks[ability].cost) < energy):
			result.append(ability)
	return result


func update_xp(amount: float) -> void:
	if level_up-xp > amount:
		xp += amount
	else:
		level += 1
		xp = amount-(level_up-xp)
		level_up = level*150


func limit_stats() -> void:
	health = clampf(health,0,stat("max_health"))
	energy = clampf(energy,0,stat("max_energy"))
