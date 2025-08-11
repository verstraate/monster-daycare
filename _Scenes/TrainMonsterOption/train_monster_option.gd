class_name TrainMonsterOption extends Button

@onready
var _name_label: Label = $Info/Name
@onready
var _icon: TextureRect = $Info/Icon
@onready
var _level_label: Label = $Info/Level
@onready
var _cost_label: Label = $Info/Cost

@onready
var _max_level_filter: ColorRect = $MaxLevelFilter

var _monster: Monster

func setup(new_monster: Monster) -> void:
	_monster = new_monster
	
	var is_max_level: bool = _monster.level >= _monster.monster_data.max_level
	
	_name_label.text = _monster.monster_data.display_name
	_icon.texture = _monster.monster_data.sprite
	_level_label.text = "Level: %d" % _monster.level
	if not is_max_level:
		_cost_label.text = "$%s" % _monster.training_cost.display_value(2)
	
	_max_level_filter.visible = is_max_level
	_max_level_filter.set_deferred("size", size)

func _on_pressed() -> void:
	if not Globals.money_manager.can_afford(_monster.training_cost):
		return
	
	Globals.money_manager.adjust_money("-%s" % _monster.training_cost.array_to_num())
	Globals.game_manager.load_training(_monster)
