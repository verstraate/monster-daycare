class_name Training extends Control

@onready
var training_status: Label = $TrainingStatus/Value
@onready
var filter: ColorRect = $TrainingFinishedFilter
@onready
var training_finished: Panel = $TrainingFinishedFilter/TrainingFinished
@onready
var old_produce_label: Label = $%OldProduce
@onready
var new_produce_label: Label = $%NewProduce

var _monster_in_training: Monster
var monster: Monster
var monster_tween: Tween
var tween_duration: float

var training_active: bool = false
@export_range(1, 50) var training_length: int = 10
var training_remaining: int = 0

@export_range(0, 10) var input_delay: float = 1
var delay_time_remaining: float = 0

func _ready() -> void:
	position.y = size.y * 2 / 3
	
	filter.color = Color(filter.color, 0)
	filter.visible = true
	training_finished.visible = false
	
	tween_duration = input_delay / 2

func _process(delta: float) -> void:
	if not training_active:
		return
	
	delay_time_remaining -= max(delta, 0)
	
	if delay_time_remaining > 0:
		return
	
	if Input.is_action_just_pressed("press"):
		training_remaining += 1
		
		training_status.text = "%d/%d" % [training_remaining, training_length]
		
		var monster_pos: Vector2 = monster.position
		monster_tween = create_tween()
		
		# JUMP UP
		monster_tween.set_trans(Tween.TRANS_CIRC)
		monster_tween.tween_property(
			monster, 
			"position",
			Vector2(monster_pos.x, monster_pos.y - monster.size.y),
			tween_duration
		)
		
		# FALL DOWN
		monster_tween.set_trans(Tween.TRANS_EXPO)
		monster_tween.tween_property(
			monster, 
			"position",
			monster_pos,
			tween_duration
		)
		
		delay_time_remaining = input_delay
	
	if training_remaining >= training_length:
		complete()

func set_monster_in_training(new_monster: Monster) -> void:
	_monster_in_training = new_monster
	
	monster = _monster_in_training.duplicate()
	add_child(monster)
	monster.position = Vector2(size.x / 2 - monster.size.x, -position.y * 1.5)
	monster.scale = Vector2.ONE * 2

func start() -> void:
	training_active = true

func complete() -> void:
	training_active = false
	
	await monster_tween.finished
	
	var filter_tween: Tween = create_tween()
	filter_tween.set_trans(Tween.TRANS_QUAD)
	filter_tween.tween_property(
		filter,
		"color",
		Color(filter.color, 1),
		tween_duration
	)
	
	await filter_tween.finished
	
	var training_cost_multiplier: float = _monster_in_training.monster_data.base_upgrade_multiplier * pow(2, _monster_in_training.level - 1)
	_monster_in_training.level += 1
	_monster_in_training.training_cost.multiply(training_cost_multiplier)
	
	var old_produce: String = _monster_in_training.produce.display_value(2)
	_monster_in_training.produce.multiply(2)
	var new_produce: String = _monster_in_training.produce.display_value(2)
	
	old_produce_label.text = "OLD: $%s" % old_produce
	new_produce_label.text = "NEW: $%s" % new_produce
	
	training_finished.visible = true
	
	await get_tree().create_timer(5).timeout
	
	Globals.game_manager.complete_training()
