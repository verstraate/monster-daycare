class_name TrainMonsterOption extends Button

@onready
var _info: VBoxContainer = $Info
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

func setup(new_monster: Monster, index: int, display_length: int) -> void:
	_monster = new_monster
	
	var is_max_level: bool = _monster.level >= _monster.monster_data.max_level
	disabled = is_max_level
	
	_name_label.text = _monster.monster_data.display_name
	_icon.texture = _monster.monster_data.sprite
	_level_label.text = "Level: %d" % _monster.level
	_cost_label.text = "$%s" % _monster.training_cost.display_value(2) if not is_max_level else ""
	
	var new_pos: Vector2 = Vector2.ZERO
	
	var x_mult: float = 0
	var y_mult: float = -0.5
	if display_length > 3:
		if index < 3:
			x_mult = float(index - 2) + 0.5
			y_mult += -0.525
		else:
			x_mult = float(index % 3) - 0.5 * (display_length % 3)
			y_mult += 0.525
	else:
		x_mult = float(index) + display_length * -0.5
	
	new_pos.x += x_mult * size.x
	new_pos.y += y_mult * size.y
	
	set_position(new_pos)
	
	_max_level_filter.visible = is_max_level

func _on_pressed() -> void:
	if not Globals.money_manager.can_afford(_monster.training_cost):
		return
	
	Globals.money_manager.adjust_money("-%s" % _monster.training_cost.array_to_num())
	Globals.game_manager.load_training(_monster)
