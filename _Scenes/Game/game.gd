class_name GameManager
extends Node2D

@onready
var _save_game_timer: Timer = $SaveGame
@onready
var _training_parent: CanvasLayer = $TrainingParent

@export var load_time: float = 2
var timer: SceneTreeTimer

const TRAINING = preload("res://_Scenes/Training/training.tscn")
var training: Training

func _ready() -> void:
	if Globals.game_manager != null and Globals.game_manager != self:
		queue_free()
		return
	
	Globals.game_manager = self
	
	get_tree().paused = true
	Globals.ui_manager.toggle_loading(true)
	
	# Fake loading timer so changing scenes feels smoother
	timer = get_tree().create_timer(load_time)
	
	SaveGame.load_game()
	SaveGame.save_game() # Override current save with idle earnings and updated values
	
	# If load_game takes longer than load_time, skip
	if timer.time_left != 0:
		await timer.timeout
	
	Globals.enclosure_manager.setup_enclosures_from_save()
	
	if len(Globals.enclosure_manager.enclosures) > 0:
		var curr_enclosure_selected: Enclosure = Globals.enclosure_manager.enclosures[Globals.enclosure_manager.selected_enclosure]
		SignalBus.selected_enclosure_changed.emit(curr_enclosure_selected)
	
	Globals.ui_manager.update_enclosure_cost_label(Globals.enclosure_manager.enclosure_cost)
	Globals.ui_manager.update_money_label(Globals.money_manager.get_money())
	
	Globals.ui_manager.toggle_loading(false)
	
	_save_game_timer.start()
	get_tree().paused = false

func load_training(monster_to_train: Monster) -> void:
	_save_game_timer.stop()
	
	timer = get_tree().create_timer(load_time / 2)
	Globals.ui_manager.toggle_loading(true)
	Globals.ui_manager.toggle_train_menu_visibility(false)
	
	SaveGame.save_game()
	
	training = TRAINING.instantiate()
	var training_pos: Vector2 = training.position
	_training_parent.add_child(training)
	training.position = training_pos
	training.set_monster_in_training(monster_to_train)
	
	if timer.time_left > 0:
		await timer.timeout
	
	SignalBus.loading_screen_timeout.connect(training.start)
	Globals.ui_manager.toggle_loading(false)

func complete_training() -> void:
	SignalBus.loading_screen_timeout.disconnect(training.start)
	
	timer = get_tree().create_timer(load_time / 2)
	Globals.ui_manager.toggle_loading(true)
	
	SignalBus.monsters_updated.emit(null)
	
	training.queue_free()
	SaveGame.save_game()
	
	if timer.time_left > 0:
		await timer.timeout
	
	Globals.ui_manager.toggle_loading(false)
	
	_save_game_timer.start()

func _on_save_game_timeout() -> void:
	SaveGame.save_game()
	_save_game_timer.start()
