class_name ProgressionManager
extends Node2D

static var Instance: ProgressionManager

var _locked_monsters: Dictionary[String, BaseMonster]

func _ready() -> void:
	if Instance != null and Instance != self:
		queue_free()
		return
	
	Instance = self

func unlock_monster(id: String) -> void:
	pass
