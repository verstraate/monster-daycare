class_name GameManager
extends Node2D

@onready
var _save_game_timer: Timer = $SaveGame
@onready
var _spawn_random_event_timer: Timer = $SpawnRandomEvent
@onready
var _training_parent: CanvasLayer = $TrainingParent
@onready
var _events: CanvasLayer = $EventContainer

@export var load_time: float = 2.0
var timer: SceneTreeTimer

var RANDOM_EVENT = preload("res://_Scenes/RandomEvent/random_event.tscn")
@export_group("RandomEvent settings")
@export_range(60.0, 600.0, 5.0) var min_event_cooldown: float
@export_range(300.0, 900.0, 5.0) var max_event_cooldown: float

const TRAINING = preload("res://_Scenes/Training/Neutral/training_neutral_01.tscn")
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
	Globals.ui_manager.update_currency_per_tick_label(Globals.money_manager.get_currency_per_tick())
	
	Globals.ui_manager.toggle_loading(false)
	
	_save_game_timer.start()
	_spawn_random_event_timer.start(_get_event_cooldown())
	get_tree().paused = false

func _get_event_cooldown() -> float:
	return Utils.rng.randf_range(min_event_cooldown, max_event_cooldown)

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
	
	SignalBus.monsters_updated.emit(null, -1)
	
	training.queue_free()
	SaveGame.save_game()
	
	if timer.time_left > 0:
		await timer.timeout
	
	Globals.ui_manager.toggle_loading(false)
	
	_save_game_timer.start()

func _on_save_game_timeout() -> void:
	SaveGame.save_game()
	_save_game_timer.start()

func _on_spawn_random_event_timeout() -> void:
	var event: RandomEvent = RANDOM_EVENT.instantiate()
	_events.add_child(event)
	_spawn_random_event_timer.start(_get_event_cooldown())
