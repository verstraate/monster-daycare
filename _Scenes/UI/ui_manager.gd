class_name UIManager
extends CanvasLayer

@onready
var _money: RichTextLabel = $%MoneyLabel
@onready
var _loading: Panel = $%Loading
@onready
var _loading_label: RichTextLabel = $%LoadingLabel
@onready
var _monster_shop: MonsterShop = $%MonsterShop

var _player_money: MoneyManager

var _loading_cycle_active: bool = true
var _loading_cycle_duration: float = 1.0
var _time_since_step: float = 0
var _loading_step: int = 0

func _ready() -> void:
	_player_money = get_tree().get_first_node_in_group("Money")
	_player_money.money_updated.connect(update_money_label)
	
	update_money_label(_player_money._money)
	
func _process(delta: float) -> void:
	if _loading_cycle_active:
		_time_since_step += delta
		if _time_since_step > _loading_cycle_duration / 3:
			_loading_label.text = "Loading%s" % "...".substr(0, (_loading_step % 3) + 1)
			
			_loading_step += 1
			_time_since_step = 0
		
	
func toggle_loading(value: bool = !_loading.visible) -> void:
	_loading_cycle_active = value
	if not value:
		_loading_label.text = "Done!"
		await get_tree().create_timer(1.5).timeout
		
	_loading.visible = value

func update_money_label(value: IdleNumber) -> void:
	_money.text = "$%s" % value.display_value(2)
