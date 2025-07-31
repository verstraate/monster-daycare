extends Node2D

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
	
