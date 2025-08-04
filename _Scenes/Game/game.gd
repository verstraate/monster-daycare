class_name GameManager
extends Node2D

static var Instance: GameManager

@onready
var _save_game_timer: Timer = $SaveGame

@export var load_time: float = 2

func _ready() -> void:
	if Instance != null and Instance != self:
		queue_free()
		return
	
	Instance = self
	
	get_tree().paused = true
	UIManager.Instance.toggle_loading(true)
	
	# Fake loading timer so changing scenes feels smoother
	var timer: SceneTreeTimer = get_tree().create_timer(load_time)
	
	SaveGame.load_game()
	
	# If load_game takes longer than load_time, skip
	if timer.time_left != 0:
		await timer.timeout
	
	EnclosureManager.Instance.setup_enclosures_from_save()
	
	UIManager.Instance.update_enclosure_cost_label(EnclosureManager.Instance.enclosure_cost)
	UIManager.Instance.update_money_label(MoneyManager.Instance.get_money())
	
	UIManager.Instance.toggle_loading(false)
	_save_game_timer.start()
	get_tree().paused = false

func _on_save_game_timeout() -> void:
	SaveGame.save_game()
	_save_game_timer.start()
