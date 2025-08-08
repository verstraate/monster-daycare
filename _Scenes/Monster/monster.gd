class_name Monster
extends TextureRect

var monster_data: BaseMonster
var produce: IdleNumber

func setup_monster(new_monster_data: BaseMonster = null):
	if new_monster_data != null:
		monster_data = new_monster_data
		produce = IdleNumber.new(monster_data.base_produce)
	
	if monster_data != null:
		texture = monster_data.sprite
		name = monster_data.display_name
