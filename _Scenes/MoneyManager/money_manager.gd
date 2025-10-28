class_name MoneyManager
extends Node2D

@export
var starting_money: String
var _money: IdleNumber

@export
var event_overlay: CanvasLayer

var current_multiplier: float = 1.0
var multiplier_timer: SceneTreeTimer

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

func generate_currency(currency: String) -> void:
	var extra_currency: IdleNumber = IdleNumber.new(currency)
	if current_multiplier != 1.0:
		extra_currency.multiply(current_multiplier)
	adjust_money(extra_currency.array_to_num())

func start_currency_event(multiplier: float, time_to_run: float) -> void:
	event_overlay.visible = true
	current_multiplier = multiplier
	multiplier_timer = get_tree().create_timer(time_to_run)
	
	if not multiplier_timer.timeout.is_connected(end_currency_event):
		multiplier_timer.timeout.connect(end_currency_event)

func end_currency_event() -> void:
	event_overlay.visible = false
	current_multiplier = 1.0

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
