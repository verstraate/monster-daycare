class_name Enclosure
extends Control

const DEFAULT_ENCLOSURE: BaseEnclosure = preload("res://Resources/Enclosures/default.tres")

var _background: TextureRect
var _capacity_label: Label
var _monster_parent: Control
var _setup: bool = false

var active_enclosure: BaseEnclosure
var current_capacity: int = 0

func setup_enclosure(new_enclosure: BaseEnclosure = null) -> void:
	if not _setup:
		_background = $%Background
		_capacity_label = $%Capacity
		_monster_parent = $%Monsters
	
	active_enclosure = new_enclosure if new_enclosure != null else DEFAULT_ENCLOSURE
	_background.texture = active_enclosure.background_sprite
	_update_capacity()
	
func add_monster(new_monster: BaseMonster) -> void:
	pass

func _update_capacity(new_capacity: int = current_capacity) -> void:
	if new_capacity != current_capacity:
		current_capacity = new_capacity
	
	_capacity_label.text = "%d/%d" % [current_capacity, active_enclosure.max_capacity]
