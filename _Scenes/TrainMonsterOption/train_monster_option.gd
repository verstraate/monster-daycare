class_name TrainMonsterOption extends Button

@onready
var _info: VBoxContainer = $Info
@onready
var _details_label: Label = $Info/Details
@onready
var _icon: TextureRect = $Info/Icon
@onready
var _cost_label: Label = $Info/Cost

@onready
var _max_level_filter: ColorRect = $MaxLevelFilter

var _monster: Monster

func setup(new_monster: Monster, index: int, display_length: int) -> void:
	_monster = new_monster
	
	var is_max_level: bool = _monster.level >= _monster.monster_data.max_level
	disabled = is_max_level
	
	_details_label.text = "%s\nLevel: %d" % [_monster.monster_data.display_name, _monster.level]
	_icon.texture = _monster.monster_data.sprite
	_cost_label.text = "$%s" % _monster.training_cost.display_value(2) if not is_max_level else ""
	
	var new_pos: Vector2 = Vector2.ZERO
	
	var max_capacity: int = Globals.enclosure_manager.enclosures[Globals.enclosure_manager.selected_enclosure].active_enclosure.max_capacity
	var new_line_threshold: int = ceili(float(max_capacity) / 2)
	var x_mult: float
	var y_mult: float = -0.5 # Centre by default
	var y_centre_offset: float = 0.55
	var x_centre_offset: float = 0.5
	
	if display_length > new_line_threshold:
		if index < new_line_threshold:
			x_mult = float(index - (new_line_threshold - 1)) + x_centre_offset
			y_mult -= y_centre_offset
		else:
			x_mult = float(index % new_line_threshold) - x_centre_offset * (display_length % new_line_threshold)
			y_mult += y_centre_offset
	else:
		x_mult = float(index) + display_length * -x_centre_offset
	
	new_pos.x += x_mult * size.x
	new_pos.y += y_mult * size.y
	
	set_position(new_pos)
	
	_max_level_filter.visible = is_max_level

func _on_pressed() -> void:
	if not Globals.money_manager.can_afford(_monster.training_cost):
		return
	
	Globals.money_manager.adjust_money("-%s" % _monster.training_cost.array_to_num())
	Globals.game_manager.load_training(_monster)
