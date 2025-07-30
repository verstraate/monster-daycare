class_name MoneyManager
extends Node2D

var _money: IdleNumber

@export
var starting_money: String

signal money_updated(value: IdleNumber)

func _ready() -> void:
	_money = IdleNumber.new(starting_money)

func get_money() -> IdleNumber:
	return _money

func adjust_money(value: String) -> void:
	if value[0] == "-":
		_money.subtract(value)
	elif value[0] == "*":
		var mult_amount: String = value.substr(1, value.length())
		_money.multiply(float(mult_amount))
	else:
		_money.add(value)
	
	money_updated.emit(_money)

func can_afford(money_to_check: IdleNumber) -> bool:
	return _money.compare(money_to_check)
	
func try_purchase(price: String) -> bool:
	if not can_afford(IdleNumber.new(price)):
		return false
	
	adjust_money("-%s" % price)
	
	return true
