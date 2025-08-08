class_name TrainMonsterOption extends Button

@onready
var _name_label: Label = $Info/Name
@onready
var _icon: TextureRect = $Info/Icon
@onready
var _level_label: Label = $Info/Level
@onready
var _cost_label: Label = $Info/Cost

var _monster: Monster
var _training_value: IdleNumber

func setup(new_monster: Monster) -> void:
	_monster = new_monster
	
	_name_label.text = _monster.monster_data.display_name
	_icon.texture = _monster.monster_data.sprite
	_level_label.text = "Level: %d" % _monster.level
	_cost_label.text = "$%s" % _monster.training_cost.display_value(2)

func _on_pressed() -> void:
	if not Globals.money_manager.can_afford(_monster.training_cost):
		return
	
	Globals.money_manager.adjust_money(_monster.training_cost.array_to_num())
	Globals.game_manager.load_training(_monster)
