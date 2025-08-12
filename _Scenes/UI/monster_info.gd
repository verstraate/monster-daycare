class_name MonsterInfo extends Panel

@onready
var _name: Label = $MonsterData/Name
@onready
var _icon: TextureRect = $MonsterData/Icon
@onready
var _type: Label = $MonsterData/Type

@onready
var _level: Label = $MonsterState/Level
@onready
var _produce: Label = $MonsterState/Produce

func _ready() -> void:
	SignalBus.monster_pressed.connect(setup)

func setup(monster: Monster):
	_name.text = monster.monster_data.display_name
	_icon.texture = monster.monster_data.sprite
	_level.text = "Level: %d/%d" % [monster.level, monster.monster_data.max_level]
	
	_type.text = str(Utils.MONSTER_TYPES.find_key(monster.monster_data.type))
	_type.add_theme_color_override("font_outline_color", Color.hex(Utils.TYPE_COLORS[monster.monster_data.type]))
	
	var produce_per_second: IdleNumber = IdleNumber.new(monster.produce.array_to_num())
	produce_per_second.multiply(10)
	_produce.text = "$%s/s" % produce_per_second.display_value(2)
