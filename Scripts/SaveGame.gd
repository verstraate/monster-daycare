extends Node2D

var keys_to_ignore: Array[String] = [
	"filename", 
	"parent", 
	"path", 
	"pos_x", 
	"pos_y",
	"scale",
	"produce",
	"level",
	"training_cost",
	"_save_time",
	"price"
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
				parent.enclosures.append(new_object)
			
			parent.add_child(new_object)
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
				new_object = new_object as MoneyManager
				_setup_idle_number(new_object, i, node_data)
				
				var save_time: Dictionary = node_data["_save_time"]
				var curr_time: Dictionary = Time.get_datetime_dict_from_system()
				
				var currency_per_tick: String = node_data["currency_per_tick"]
				var afk_earnings: IdleNumber = _generate_afk_earnings(save_time, curr_time, currency_per_tick)
				new_object.adjust_money(afk_earnings.array_to_num())
				continue
			
			if i == "enclosure_cost" or i == "currency_per_tick":
				_setup_idle_number(new_object, i, node_data)
				continue
			
			if i == "_all_monster_types":
				new_object = new_object as EnclosureManager
				var _all_monster_types: Dictionary[Utils.MONSTER_TYPES, int] = {}
				var _all_monster_preferences: Dictionary[Utils.MONSTER_TYPES, float] = {}
				
				for j in node_data[i]:
					_all_monster_types[int(j)] = int(node_data["_all_monster_types"][j])
					_all_monster_preferences[int(j)] = float(node_data["_all_monster_preferences"][j])
				
				new_object._all_monster_types = _all_monster_types
				new_object._all_monster_preferences = _all_monster_preferences
				continue
			
			if i == "locked_monsters":
				_setup_resource_array(new_object, i, node_data)
				continue
			
			if i == "monsters":
				new_object = new_object as Enclosure
				_setup_monsters(node_data[i], new_object)
				continue
			
			if i == "active_enclosure":
				new_object.set(i, load(node_data[i]))
				continue
			
			if i == "monsters_for_sale":
				_setup_monster_shop(new_object, i, node_data)
				continue
			
			new_object.set(i, node_data[i])
		
		line_count += 1

func _setup_idle_number(new_object, i: String, node_data: Dictionary) -> void:
	var num: IdleNumber = IdleNumber.new(node_data[i])
	new_object.set(i, num)

func _setup_resource_array(new_object, i: String, node_data: Dictionary) -> void:
	var array_to_set: Array
	for res in node_data[i]:
		array_to_set.append(load(res))
	new_object.set(i, array_to_set)

func _setup_monsters(monsters: Array, new_object: Enclosure) -> void:
	var monsters_to_add: Array[Monster] = []
	for monster in monsters:
		var new_monster: Monster = MONSTER.instantiate()
		new_object.add_child(new_monster)
		new_monster.position = Vector2(monster["pos_x"], monster["pos_y"])
		new_monster.scale = Vector2.ONE * monster["scale"]
		new_monster.produce = IdleNumber.new(monster["produce"])
		new_monster.training_cost = IdleNumber.new(monster["training_cost"])
		new_monster.level = monster["level"]
		new_monster.monster_data = load(monster["monster_data"]) as BaseMonster
		monsters_to_add.append(new_monster)
	
	new_object.monsters = monsters_to_add

func _setup_monster_shop(new_object: MonsterShop, i: String, node_data: Dictionary) -> void:
	var monsters_for_sale: Array[BaseMonster] = []
	for monster in node_data[i]:
		monsters_for_sale.append(load(node_data[i][monster]["data"]))
	new_object.set_monsters_for_sale(monsters_for_sale)
	for item in node_data[i]:
		if not new_object.monsters_displayed.has(item):
			continue
		var curr_item: ShopItem = new_object.monsters_displayed[item]
		curr_item.price = IdleNumber.new(node_data[i][item]["price"])
		curr_item.price_label.text = "$%s" % curr_item.price.display_value(2)

func _generate_afk_earnings(save_time: Dictionary, curr_time: Dictionary, currency_per_tick: String) -> IdleNumber:
	var currency: IdleNumber = IdleNumber.new(currency_per_tick) # Currency generated per tick (0.1s)
	
	# GENERATE TIME AMOUNT CONSTANTS
	currency.multiply(10) # 0.1s -> 1s
	var second_total: IdleNumber = IdleNumber.new(currency.array_to_num())
	currency.multiply(60) # 1s -> 60s -> 1m
	var minute_total: IdleNumber = IdleNumber.new(currency.array_to_num())
	currency.multiply(60) # 1m -> 60m -> 1hr
	var hour_total: IdleNumber = IdleNumber.new(currency.array_to_num())
	currency.multiply(24) # 1hr -> 24hr -> 1 day
	var day_total: IdleNumber = IdleNumber.new(currency.array_to_num())
	currency.multiply(30) # 1 day -> 30 days -> 1 month, close enough
	var month_total: IdleNumber = IdleNumber.new(currency.array_to_num())
	currency.multiply(12) # 1 month -> 12 months -> 1 year (360 days)
	var year_total: IdleNumber = IdleNumber.new(currency.array_to_num())
	
	# DIFFERENCE BETWEEN save_time AND curr_time
	var seconds: int = max(0, curr_time["second"] - save_time["second"])
	var minutes: int = max(0, curr_time["minute"] - save_time["minute"])
	var hours: int = max(0, curr_time["hour"] - save_time["hour"])
	var days: int = max(0, curr_time["day"] - save_time["day"])
	var months: int = max(0, curr_time["month"] - save_time["month"])
	var years: int = max(0, curr_time["year"] - save_time["year"])
	
	# CALCULATE EARNINGS
	
	second_total.multiply(seconds)
	minute_total.multiply(minutes)
	hour_total.multiply(hours)
	day_total.multiply(days)
	month_total.multiply(months)
	year_total.multiply(years)
	
	var total_earnings: IdleNumber = IdleNumber.new()
	total_earnings.add(second_total.array_to_num())
	total_earnings.add(minute_total.array_to_num())
	total_earnings.add(hour_total.array_to_num())
	total_earnings.add(day_total.array_to_num())
	total_earnings.add(month_total.array_to_num())
	total_earnings.add(year_total.array_to_num())
	
	return total_earnings
