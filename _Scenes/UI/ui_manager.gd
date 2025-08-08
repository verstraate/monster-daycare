class_name UIManager
extends CanvasLayer

@onready
var _loading: Panel = $%Loading
@onready
var _loading_label: RichTextLabel = $%LoadingLabel

@onready
var _money: RichTextLabel = $%MoneyLabel
@onready
var _enclosure_cost: Label = $%EnclosureCost

@onready
var _train_menu: TrainMenu = $%TrainMenu
@onready
var _train_menu_container: Button = $TrainMenuContainer

var _loading_cycle_active: bool = true
var _loading_cycle_duration: float = 1.0
var _time_since_step: float = 0
var _loading_step: int = 0

signal loading_timeout

func _ready() -> void:
	if Globals.ui_manager != null and Globals.ui_manager != self:
		queue_free()
		return
	
	Globals.ui_manager = self
	
	Globals.money_manager.money_updated.connect(update_money_label)
	update_money_label(Globals.money_manager.get_money())
	
	Globals.enclosure_manager.cost_updated.connect(update_enclosure_cost_label)
	update_enclosure_cost_label(Globals.enclosure_manager.enclosure_cost)
	
	toggle_train_menu_visibility(false)

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
		loading_timeout.emit()
		layer = 1
	else:
		layer = 10
	
	_loading.visible = value

func update_money_label(value: IdleNumber) -> void:
	_money.text = "$%s" % value.display_value(2)

func update_enclosure_cost_label(value: IdleNumber) -> void:
	_enclosure_cost.text = "$%s" % value.display_value(2)

func toggle_train_menu_visibility(value: bool) -> void:
	_train_menu_container.visible = value

func _on_train_button_pressed() -> void:
	#_train_menu.change_enclosure(Globals.enclosure_manager.selected_enclosure)
	#toggle_train_menu_visibility(true)
	if len(Globals.enclosure_manager.enclosures) == 0:
		return
	
	var temp_enclosure: Enclosure = Globals.enclosure_manager.enclosures[Globals.enclosure_manager.selected_enclosure]
	
	if len(temp_enclosure.monsters) == 0:
		return
	
	var temp_monster: Monster = temp_enclosure.monsters[0]
	Globals.game_manager.load_training(temp_monster)

func _on_train_menu_container_pressed() -> void:
	toggle_train_menu_visibility(false)

func _on_close_train_menu_pressed() -> void:
	toggle_train_menu_visibility(false)
