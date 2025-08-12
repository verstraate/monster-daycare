class_name Monster
extends TextureButton

var monster_data: BaseMonster
var produce: IdleNumber
var training_cost: IdleNumber
var level: int = 1

func setup_monster(new_monster_data: BaseMonster = null):
	if new_monster_data != null:
		monster_data = new_monster_data
		produce = IdleNumber.new(monster_data.base_produce)
		training_cost = IdleNumber.new(monster_data.base_upgrade)
	
	if monster_data != null:
		texture_normal = monster_data.sprite
		texture_pressed = monster_data.sprite
		texture_hover = monster_data.sprite
		texture_disabled = monster_data.sprite
		texture_focused = monster_data.sprite
		name = monster_data.display_name

func _on_pressed() -> void:
	SignalBus.monster_pressed.emit(self)
