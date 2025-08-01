extends Node2D

@onready
var _save_game_timer: Timer = $SaveGame
@onready
var _ui_manager: UIManager = $UI
@onready
var _money_manager: MoneyManager = $MoneyManager
var _enclosure_manager: EnclosureManager

@export var load_time: float = 2

func _ready() -> void:
	get_tree().paused = true
	
	_ui_manager.toggle_loading(true)
	
	# Fake loading timer so changing scenes feels smoother
	var timer_complete: bool = false
	var timer: SceneTreeTimer = get_tree().create_timer(load_time)
	timer.timeout.connect(func(): timer_complete = true)
	
	SaveGame.load_game()
	
	# If load_game takes longer than load_time, skip
	if not timer_complete:
		await timer.timeout
	
	_ui_manager.update_money_label(_money_manager.get_money())
	_enclosure_manager = get_tree().get_first_node_in_group("Enclosures")
	_enclosure_manager.setup_enclosures_from_save()
	
	_ui_manager.toggle_loading(false)
	
	_save_game_timer.start()
	get_tree().paused = false

func _on_save_game_timeout() -> void:
	SaveGame.save_game()
	_save_game_timer.start()
