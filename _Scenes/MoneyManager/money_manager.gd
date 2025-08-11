class_name MoneyManager
extends Node2D

@export
var starting_money: String
var _money: IdleNumber

signal money_updated(value: IdleNumber)

func _ready() -> void:
	if Globals.money_manager != null and Globals.money_manager != self:
		queue_free()
		return
	
	Globals.money_manager = self
	
	_money = IdleNumber.new(starting_money)

func get_money() -> IdleNumber:
	return _money

func adjust_money(value: String) -> void:
	if len(value) < 1:
		return
	
	if value[0] == "-":
		var sub_amount: String = value.substr(1, len(value))
		_money.subtract(sub_amount)
	elif value[0] == "*":
		var mult_amount: String = value.substr(1, len(value))
		_money.multiply(float(mult_amount))
	else:
		_money.add(value)
	
	SignalBus.money_updated.emit(_money)

func can_afford(money_to_check: IdleNumber) -> bool:
	return _money.compare(money_to_check)
	
func try_purchase(price: String) -> bool:
	if not can_afford(IdleNumber.new(price)):
		return false
	
	adjust_money("-%s" % price)
	
	return true
	
func save() -> Dictionary:
	return {
		"path": get_path(),
		"_money": _money.array_to_num(),
		"_save_time": Time.get_datetime_dict_from_system(),
		"currency_per_tick": Globals.enclosure_manager.currency_per_tick.array_to_num()
	}

func load_save(data: Dictionary) -> void:
	_money = IdleNumber.new(data["_money"])

func _on_tick_timeout() -> void:
	SignalBus.money_tick.emit()
