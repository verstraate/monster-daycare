class_name TrainMenu extends Panel

const TRAIN_MONSTER_OPTION = preload("res://_Scenes/TrainMonsterOption/train_monster_option.tscn")

@onready
var _monsters_parent: HFlowContainer = $Monsters

var current_enclosure: Enclosure
var _monsters_displayed: Array[TrainMonsterOption] = []

func _ready() -> void:
	SignalBus.selected_enclosure_changed.connect(_on_enclosure_changed)

func _on_enclosure_changed(new_enclosure: Enclosure) -> void:
	if current_enclosure != null:
		SignalBus.monsters_updated.disconnect(_update_monsters)
	
	current_enclosure = new_enclosure
	SignalBus.monsters_updated.connect(_update_monsters)
	
	_update_monsters()

func _update_monsters() -> void:
	var monsters_to_display: Array[Monster] = current_enclosure.monsters
	
	var to_display_length: int = len(monsters_to_display)
	if to_display_length == 0:
		for i in range(len(_monsters_displayed)):
			_monsters_displayed[i].visible = false
		return
	
	if len(_monsters_displayed) < current_enclosure.active_enclosure.max_capacity:
		for i in range(current_enclosure.active_enclosure.max_capacity):
			var new_monster: TrainMonsterOption = TRAIN_MONSTER_OPTION.instantiate()
			_monsters_parent.add_child(new_monster)
			_monsters_displayed.append(new_monster)
	
	if to_display_length < len(_monsters_displayed):
		for i in range(to_display_length, len(_monsters_displayed)):
			_monsters_displayed[i].visible = false
	
	for i in range(to_display_length):
		_monsters_displayed[i].setup(monsters_to_display[i])
		_monsters_displayed[i].visible = true
