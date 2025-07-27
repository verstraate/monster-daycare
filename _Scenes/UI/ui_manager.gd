class_name UIManager
extends CanvasLayer

@onready
var _money: RichTextLabel = $%MoneyLabel

var _player_money: MoneyManager

func _ready() -> void:
	_player_money = get_tree().get_first_node_in_group("Money")
	_player_money.money_updated.connect(update_money_label)
	
	update_money_label(_player_money._money)

func update_money_label(value: IdleNumber):
	_money.text = value.display_value(2)
