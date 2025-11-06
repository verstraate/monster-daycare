class_name UIManager
extends CanvasLayer

@onready
var _loading: Panel = $%Loading
@onready
var _loading_label: RichTextLabel = $%LoadingLabel

@onready
var _money: RichTextLabel = $%MoneyLabel
@onready
var _currency_per_tick: Label = $%CurrencyPerTickLabel
@onready
var _enclosure_cost: Label = $%EnclosureCost

@onready
var _train_menu_container: Button = $TrainMenuContainer
@onready
var _monster_info: Button = $MonsterInfo

signal monster_info_toggled(monster: Monster)

var _loading_cycle_active: bool = true
var _loading_cycle_duration: float = 1.0
var _time_since_step: float = 0
var _loading_step: int = 0

func _ready() -> void:
	if Globals.ui_manager != null and Globals.ui_manager != self:
		queue_free()
		return
	
	Globals.ui_manager = self
	
	SignalBus.money_updated.connect(update_money_label)
	SignalBus.currency_per_tick_updated.connect(update_currency_per_tick_label)
	update_money_label(Globals.money_manager.get_money())
	update_currency_per_tick_label(Globals.money_manager.get_currency_per_tick())
	
	SignalBus.enclosure_cost_updated.connect(update_enclosure_cost_label)
	update_enclosure_cost_label(Globals.enclosure_manager.enclosure_cost)
	
	SignalBus.monster_pressed.connect(_on_monster_pressed)
	SignalBus.event_started.connect(_on_event_started)
	
	toggle_train_menu_visibility(false)
	toggle_monster_info_visibility(false)

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
		SignalBus.loading_screen_timeout.emit()
		layer = 1
	else:
		layer = 10
	
	_loading.visible = value

func update_money_label(value: IdleNumber) -> void:
	_money.text = "$%s" % value.display_value(2)

func update_currency_per_tick_label(value: IdleNumber) -> void:
	print(value.array_to_num())
	var temp_value: IdleNumber = IdleNumber.new(value.array_to_num())
	temp_value.multiply(10.0)
	
	var display_value: String = temp_value.display_value(2)
	_currency_per_tick.text = "+$%s/s" % display_value

func _on_event_started(multiplier: float, _duration: float) -> void:
	var currency: IdleNumber = Globals.money_manager.get_currency_per_tick()
	var new_currency: IdleNumber = IdleNumber.new(currency.array_to_num())
	new_currency.multiply(multiplier)
	
	update_currency_per_tick_label(new_currency)

func update_enclosure_cost_label(value: IdleNumber) -> void:
	_enclosure_cost.text = "$%s" % value.display_value(2)

func toggle_train_menu_visibility(value: bool) -> void:
	_train_menu_container.visible = value

func toggle_monster_info_visibility(value: bool) -> void:
	_monster_info.visible = value

func _on_train_button_pressed() -> void:
	toggle_train_menu_visibility(true)

func _on_train_menu_container_pressed() -> void:
	toggle_train_menu_visibility(false)

func _on_close_train_menu_pressed() -> void:
	toggle_train_menu_visibility(false)

func _on_monster_pressed(_monster: Monster) -> void:
	toggle_monster_info_visibility(true)

func _on_monster_info_pressed() -> void:
	toggle_monster_info_visibility(false)

func _on_close_monster_info_pressed() -> void:
	toggle_monster_info_visibility(false)
