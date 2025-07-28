class_name MoneyManager
extends Node2D

var _money: IdleNumber = IdleNumber.new()

@export
var starting_money: String

signal money_updated(value: IdleNumber)

func _ready() -> void:
	adjust_money(starting_money)

func get_money() -> IdleNumber:
	return _money

func adjust_money(value: String) -> void:
	if value[0] == "-":
		_money.subtract(value)
	else:
		_money.add(value)
	
	money_updated.emit(_money)
