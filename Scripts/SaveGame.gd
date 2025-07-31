extends Node2D

func save_game() -> void:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	for node in save_nodes:
		if !node.has_method("save"):
			print("Node %s is missing a save() function, skipped." % node.name)
			continue
		
		var node_data: Dictionary = node.call("save")
		var json_string: String = JSON.stringify(node_data)
		
		save_file.store_line(json_string)

func load_game() -> void:
	pass
