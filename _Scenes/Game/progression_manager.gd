class_name ProgressionManager
extends Node2D

@export var locked_monsters: Array[BaseMonster]
var _unlock_requirements: Dictionary[String, IdleNumber] = {}

func _ready() -> void:
	if Globals.progression_manager != null and Globals.progression_manager != self:
		queue_free()
		return
	
	Globals.progression_manager = self
	
	for monster in locked_monsters:
		_unlock_requirements[monster.id] = IdleNumber.new(monster.price)
	
	SignalBus.money_updated.connect(check_for_unlocks)

func check_for_unlocks(money: IdleNumber) -> void:
	var monsters: Array[BaseMonster] = []
	var monsters_to_check: Array[BaseMonster] = locked_monsters.duplicate()
	for i in range(len(monsters_to_check) - 1, -1, -1):
		if money.compare(_unlock_requirements[monsters_to_check[i].id]):
			monsters.append(locked_monsters.pop_at(i))
	
	if len(monsters) > 0:
		unlock_monsters(monsters)

func unlock_monsters(monsters: Array[BaseMonster]) -> void:
	for monster in monsters:
		if _unlock_requirements.has(monster.id):
			_unlock_requirements.erase(monster.id)
	
	Globals.monster_shop.add_monsters_to_shop(monsters)

func save() -> Dictionary:
	var locked_monsters_to_save: Array[String]
	for monster in locked_monsters:
		locked_monsters_to_save.append(monster.resource_path)
	
	return {
		"path": get_path(),
		"locked_monsters": locked_monsters_to_save
	}
