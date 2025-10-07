class_name EnclosureManager
extends Control

const ENCLOSURE_SCENE = preload("res://_Scenes/Enclosure/enclosure.tscn")
var _tween: Tween

var currency_per_tick: IdleNumber = IdleNumber.new()
var _all_monster_types: Dictionary[int, Array] = {}
var _all_monster_preferences: Dictionary[int, Array] = {}

@export_group("Enclosure Cost")
@export var enclosure_start_cost: String
@export_range(1, 1000) var enclosure_cost_rate: float = 100
var enclosure_cost: IdleNumber = IdleNumber.new("0")

var enclosures: Array[Enclosure] = []
var selected_enclosure: int = 0

@onready
var animation_timer: Timer = $MonsterMove
var animation_chance: int = 30
var max_animation_time: float
var max_monster_pos_y: float

@export_group("Swipe")
@export_range(100, 500) var swipe_threshold: int
@export_range(0, 1) var swipe_duration: float
var swipe_dir: int = 0

var swiping: bool = false
var first_swipe_position: Vector2
var curr_swipe_position: Vector2

func _ready() -> void:
	if Globals.enclosure_manager != null and Globals.enclosure_manager != self:
		queue_free()
		return
	
	Globals.enclosure_manager = self
	
	SignalBus.money_tick.connect(_generate_currency)
	SignalBus.monsters_updated.connect(_on_monster_added)
	SignalBus.selected_enclosure_changed.connect(get_max_monster_y)
	
	max_animation_time = animation_timer.wait_time / 2
	animation_timer.timeout.connect(_run_animation)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("press") and not swiping:
		var mouse_pos = get_global_mouse_position()
		swiping = get_rect().has_point(mouse_pos)
		if swiping:
			first_swipe_position = mouse_pos
			curr_swipe_position = first_swipe_position
		
	if Input.is_action_pressed("press") and swiping:
		curr_swipe_position = get_global_mouse_position()
		if first_swipe_position.distance_to(curr_swipe_position) >= swipe_threshold:
			var swipe_angle: float = abs(Vector2(first_swipe_position - curr_swipe_position).angle())
			swipe_dir = 1 if swipe_angle > PI / 2 else -1
			_handle_swipe()
			swiping = false
				
	if Input.is_action_just_released("press") and swiping:
		swiping = false

func setup_enclosures_from_save() -> void:
	if len(enclosures) == 0:
		return
	
	for enclosure in enclosures:
		enclosure.setup_enclosure(null, true)

func get_max_monster_y(new_enclosure: Enclosure) -> void:
	max_monster_pos_y =  4.0 / 7.0 * new_enclosure.size.y + 100
	print("max_monster_pos_y: %d" % max_monster_pos_y)

func get_random_monster_pos(monster: Monster) -> Vector2:
	return Vector2(Utils.rng.randf_range(10, enclosures[selected_enclosure].size.x - 10 - monster.size.x), Utils.rng.randf_range(max_monster_pos_y - 100, max_monster_pos_y))

func _run_animation() -> void:
	if len(enclosures) == 0:
		return
	
	for monster in enclosures[selected_enclosure].monsters:
		if monster.animate_tween and monster.animate_tween.is_running():
			continue
		
		if Utils.rng.randi() % 100 < animation_chance:
			var new_pos: Vector2 = get_random_monster_pos(monster)
			var new_scale: Vector2 = Vector2.ONE * (new_pos.y / max_monster_pos_y)
			
			var max_distance_x: float = enclosures[selected_enclosure].size.x - 10 - monster.size.x
			var distance_to_move: float = monster.position.distance_to(new_pos)
			var time_to_tween: float = clampf(max_animation_time * (distance_to_move / max_distance_x), 0, max_animation_time)
			
			monster.animate_tween = create_tween()
			monster.animate_tween.set_parallel()
			monster.animate_tween.tween_property(monster, "position", new_pos, time_to_tween)
			monster.animate_tween.tween_property(monster, "scale", new_scale, time_to_tween)

func _add_enclosure(new_enclosure: BaseEnclosure = null) -> void:
	if _tween != null and _tween.is_running():
		return
	
	if not Globals.money_manager.try_purchase(enclosure_cost.array_to_num()):
		return
	
	if enclosures.size() > 0:
		enclosure_cost.multiply(enclosure_cost_rate)
	else:
		enclosure_cost.set_value(enclosure_start_cost)
	SignalBus.enclosure_cost_updated.emit(enclosure_cost)
	
	var pos_mod: int = 0 if enclosures.size() == 0 else 1
	var enclosure: Enclosure = ENCLOSURE_SCENE.instantiate()
	add_child(enclosure)
	enclosure.setup_enclosure(new_enclosure)
	enclosure.position = Vector2(pos_mod * enclosure.size.x, enclosure.position.y)
	enclosures.append(enclosure)
	
	# If new enclosure is the first, skip swipe animation
	if enclosures.size() < 2:
		enclosure.position = Vector2.ZERO
	
	var curr_enclosure: Enclosure = enclosures[selected_enclosure]
	var curr_enclosure_target: Vector2 = Vector2(curr_enclosure.size.x * -1, curr_enclosure.position.y)
	
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(curr_enclosure, "position", curr_enclosure_target, swipe_duration)
	_tween.tween_property(enclosure, "position", Vector2.ZERO, swipe_duration)
	
	selected_enclosure = enclosures.size() - 1
	
	var new_types: Array = []
	new_types.resize(len(Utils.MONSTER_TYPES))
	new_types.fill(0.0)
	_all_monster_types[selected_enclosure] = new_types.duplicate()
	_all_monster_preferences[selected_enclosure] = new_types.duplicate()
	
	SignalBus.selected_enclosure_changed.emit(enclosures[selected_enclosure])

func _handle_swipe() -> void:
	if _tween != null and _tween.is_running():
		return
	
	# If an enclosure doesn't exist that the player is attempting to bring on screen, return early.
	if (selected_enclosure - 1 < 0 and swipe_dir > 0) or (selected_enclosure + 1 > enclosures.size() - 1 and swipe_dir < 0):
		return
	
	var next_enclosure: int = selected_enclosure - swipe_dir
	var target_enclosure: Enclosure = enclosures[next_enclosure]
	target_enclosure.position = Vector2(target_enclosure.size.x * -swipe_dir, target_enclosure.position.y)
	
	var curr_enclosure: Enclosure = enclosures[selected_enclosure]
	var curr_enclosure_target: Vector2 = Vector2(curr_enclosure.size.x * swipe_dir, curr_enclosure.position.y)
	
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(curr_enclosure, "position", curr_enclosure_target, swipe_duration)
	_tween.tween_property(target_enclosure, "position", Vector2.ZERO, swipe_duration)
	
	selected_enclosure = next_enclosure
	SignalBus.selected_enclosure_changed.emit(enclosures[selected_enclosure])

func _generate_currency() -> void:
	Globals.money_manager.adjust_money(currency_per_tick.array_to_num())

func _on_monster_added(new_monster: Monster, enclosure_index: int) -> void:
	if new_monster == null || enclosure_index == -1:
		_get_currency_per_tick()
		return
	
	var monster_type: Utils.MONSTER_TYPES = new_monster.monster_data.type
	if _all_monster_types[enclosure_index][monster_type] != 0:
		_all_monster_types[enclosure_index][monster_type] += 1
	else:
		_all_monster_types[enclosure_index][monster_type] = 1
	
	# NEW MONSTER INCREASES/DECREASES OTHER MONSTERS BY PREF
	for i in range(len(_all_monster_types[enclosure_index])):
		if i == monster_type or _all_monster_types[enclosure_index][i] == 0:
			continue
		
		var pref: int = Utils.TYPE_PREFERENCES[i][monster_type]
		if pref == 0:
			continue
			
		if _all_monster_preferences[enclosure_index][i] == 0:
			_all_monster_preferences[enclosure_index][i] = 1
			continue
		
		_all_monster_preferences[enclosure_index][i] *= 1.5 if pref > 0 else 0.5
	
	# SET NEW MONSTER'S TYPE TO DEFAULT
	_all_monster_preferences[enclosure_index][monster_type] = 1
	
	# OTHER MONSTERS INCREASE/DECREASE NEW MONSTER BY PREF
	for i in range(len(_all_monster_types[enclosure_index])):
		if _all_monster_types[enclosure_index][i] == 0:
			continue
		
		var pref: int = Utils.TYPE_PREFERENCES[monster_type][i]
		if pref == 0:
			continue
		
		var monsters_of_type: int = _all_monster_types[enclosure_index][i]
		var power: int = max(0, monsters_of_type if i != monster_type else monsters_of_type - 1)
		_all_monster_preferences[enclosure_index][monster_type] *= pow(1 + pref * 0.5, power)
	
	_get_currency_per_tick()

func _get_currency_per_tick() -> void:
	var currency: IdleNumber = IdleNumber.new()
	
	for i in range(len(enclosures)):
		for j in range(len(enclosures[i].monsters)):
			var monster: Monster = enclosures[i].monsters[j]
			var currency_to_add: IdleNumber = IdleNumber.new(monster.produce.array_to_num())
			currency_to_add.multiply(_all_monster_preferences[i][monster.monster_data.type])
			currency.add(currency_to_add.array_to_num())
	
	currency_per_tick = currency

func save() -> Dictionary:
	return {
		"path": get_path(),
		"selected_enclosure": selected_enclosure,
		"_all_monster_types": _all_monster_types,
		"_all_monster_preferences": _all_monster_preferences,
		"currency_per_tick": currency_per_tick.array_to_num(),
		"enclosure_cost": enclosure_cost.array_to_num(),
	}

func _on_add_enclosure_pressed() -> void:
	_add_enclosure()
