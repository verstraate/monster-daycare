extends Node2D

var keys_to_ignore: Array[String] = [
	"filename", 
	"parent", 
	"path", 
	"pos_x", 
	"pos_y",
	"scale",
	"_save_time"
]

const MONSTER = preload("res://_Scenes/Monster/monster.tscn")

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
	var save_file_path: String = "user://savegame.save"
	if not FileAccess.file_exists(save_file_path):
		print("Save file doesn't exist, skipped loading.")
		return
	
	var line_count: int = 1
	var save_file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string: String = save_file.get_line()
		
		var json: JSON = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print('Error: %s in %s at line %d' % [json.get_error_message(), json_string, json.get_error_line()])
			continue
		
		var node_data: Dictionary = json.data
		
		var new_object
		if node_data.has("filename"):
			new_object = load(node_data["filename"]).instantiate()
			
			var parent = get_node(node_data["parent"])
			if new_object is Enclosure and parent is EnclosureManager:
				parent = parent as EnclosureManager
				parent.add_child(new_object)
				parent.enclosures.append(new_object)
			
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		if node_data.has("path"):
			new_object = get_node(node_data["path"])
			
		if not new_object:
			print("Node not created nor retrieved at line %d, skipped." % [line_count])
			continue
		
		for i in node_data.keys():
			if keys_to_ignore.has(i):
				continue
			
			if i == "_money":
				_setup_money(node_data[i], new_object)
				continue
			
			if i == "monsters":
				_setup_monsters(node_data[i], new_object)
				continue
			
			if i == "active_enclosure":
				new_object.set(i, load(node_data[i]))
				continue
			
			new_object.set(i, node_data[i])
		
		line_count += 1

func _setup_money(value: String, new_object: MoneyManager) -> void:
	var money: IdleNumber = IdleNumber.new(value)
	new_object._money = money

func _setup_monsters(monsters: Array, new_object: Enclosure) -> void:
	var monsters_to_add: Array[Monster] = []
	for monster in monsters:
		var new_monster: Monster = MONSTER.instantiate()
		new_object.add_child(new_monster)
		new_monster.position = Vector2(monster["pos_x"], monster["pos_y"])
		new_monster.scale = Vector2.ONE * monster["scale"]
		new_monster.monster_data = load(monster["monster_data"]) as BaseMonster
		monsters_to_add.append(new_monster)
	
	new_object.monsters = monsters_to_add
