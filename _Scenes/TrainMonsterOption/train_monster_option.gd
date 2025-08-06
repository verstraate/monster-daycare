class_name TrainMonsterOption extends Button

@onready
var _name_label: Label = $Info/Name
@onready
var _icon: TextureRect = $Info/Icon
@onready
var _cost_label: Label = $Info/Cost

var _monster: Monster
@export_range(100, 10000) var training_cost: int = 100

func setup(new_monster: Monster) -> void:
	_monster = new_monster
	
	_name_label.text = _monster.monster_data.display_name
	_icon.texture = _monster.monster_data.sprite
	_cost_label.text = "$%d" % training_cost


func _on_pressed() -> void:
	pass
