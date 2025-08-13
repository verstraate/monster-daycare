class_name Enclosure
extends Control

const DEFAULT_ENCLOSURE: BaseEnclosure = preload("res://Resources/Enclosures/default.tres")

var _background: TextureRect
var _capacity_label: Label
var _monster_parent: Control
var _setup: bool = false

var active_enclosure: BaseEnclosure
var monsters: Array[Monster] = []

func setup_enclosure(new_enclosure: BaseEnclosure = null, from_save: bool = false) -> void:
	if not _setup:
		_background = $%Background
		_capacity_label = $%Capacity
		_monster_parent = $%Monsters
	
	if active_enclosure == null:
		active_enclosure = new_enclosure if new_enclosure != null else DEFAULT_ENCLOSURE
	
	if from_save:
		for monster in monsters:
			monster.setup_monster()
	
	_background.texture = active_enclosure.background_sprite
	_update_capacity()

func at_max_capacity() -> bool:
	return monsters.size() == active_enclosure.max_capacity

func try_add_monster(new_monster: Monster) -> bool:
	if at_max_capacity():
		return false
	
	_monster_parent.add_child(new_monster)
	var pos_y: float =  4.0 / 7.0 * size.y + 100
	new_monster.set_position(Vector2(Utils.rng.randf_range(10, size.x - 10 - new_monster.size.x), Utils.rng.randf_range(pos_y - 100, pos_y)), true)
	new_monster.scale = Vector2.ONE * (new_monster.position.y / pos_y)
	monsters.append(new_monster)
	
	_update_capacity()
	SignalBus.monsters_updated.emit(new_monster, Globals.enclosure_manager.selected_enclosure)
	return true

func _update_capacity() -> void:
	_capacity_label.text = "%d/%d" % [monsters.size(), active_enclosure.max_capacity]

func save() -> Dictionary:
	var monsters_to_save: Array[Dictionary] = []
	
	for monster in monsters:
		monsters_to_save.append({
			"monster_data": monster.monster_data.resource_path,
			"pos_x": monster.position.x,
			"pos_y": monster.position.y,
			"scale": monster.scale.x,
			"produce": monster.produce.array_to_num(),
			"training_cost": monster.training_cost.array_to_num(),
			"level": monster.level
		})
	
	return {
		"filename": scene_file_path,
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"active_enclosure": active_enclosure.resource_path,
		"monsters": monsters_to_save,
	}
