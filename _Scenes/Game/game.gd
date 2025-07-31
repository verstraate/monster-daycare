extends Node2D

@onready
var _save_game_timer: Timer = $SaveGame
var _ui_manager: UIManager

func _ready() -> void:
	get_tree().paused = true
	#await SaveGame.load_game()
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	
	for node in get_children():
		if node is UIManager:
			_ui_manager = node
	
	_ui_manager.toggle_loading()

func _on_save_game_timeout() -> void:
	print('saving...')
	SaveGame.save_game()
	print('...saved!')
	_save_game_timer.start()
