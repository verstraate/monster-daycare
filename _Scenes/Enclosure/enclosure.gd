class_name Enclosure
extends Control

const DEFAULT_ENCLOSURE: BaseEnclosure = preload("res://Resources/Enclosures/default.tres")

var _background: TextureRect
var _capacity_label: Label
var _monster_parent: Control
var _setup: bool = false

var active_enclosure: BaseEnclosure
var monsters: Array[Monster] = []

func setup_enclosure(new_enclosure: BaseEnclosure = null) -> void:
	if not _setup:
		_background = $%Background
		_capacity_label = $%Capacity
		_monster_parent = $%Monsters
	
	active_enclosure = new_enclosure if new_enclosure != null else DEFAULT_ENCLOSURE
	_background.texture = active_enclosure.background_sprite
	_update_capacity()
	
func try_add_monster(new_monster: Monster) -> bool:
	if monsters.size() == active_enclosure.max_capacity:
		return false
	
	_monster_parent.add_child(new_monster)
	new_monster.set_position(Vector2(Utils.rng.randf_range(100, size.x - 100), 4.0 / 7.0 * size.y), true)
	monsters.append(new_monster)
	
	_update_capacity()
	return true

func _update_capacity() -> void:
	_capacity_label.text = "%d/%d" % [monsters.size(), active_enclosure.max_capacity]
