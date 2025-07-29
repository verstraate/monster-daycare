class_name Monster
extends TextureRect

var monster_data: BaseMonster

func setup_monster(new_monster_data: BaseMonster):
	monster_data = new_monster_data
	
	texture = monster_data.sprite
	name = monster_data.display_name
