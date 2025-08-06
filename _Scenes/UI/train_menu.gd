class_name TrainMenu extends Panel

const TRAIN_MONSTER_OPTION = preload("res://_Scenes/TrainMonsterOption/train_monster_option.tscn")

@onready
var _monsters_parent: HBoxContainer = $Monsters

var current_enclosure: int = -1
var _monsters_displayed: Array[TrainMonsterOption] = []

signal enclosure_changed()

func _ready() -> void:
	enclosure_changed.connect(_update_monsters)

func change_enclosure(new_enclosure: int) -> void:
	if current_enclosure == new_enclosure:
		return
	
	current_enclosure = new_enclosure
	enclosure_changed.emit()

func _update_monsters() -> void:
	var enclosure: Enclosure = EnclosureManager.Instance.enclosures[current_enclosure]
	var monsters_to_display: Array[Monster] = enclosure.monsters
	
	var to_display_length: int = len(monsters_to_display)
	if to_display_length == 0:
		return
	
	var diff: int = len(_monsters_displayed) - len(monsters_to_display)
	if diff < 0:
		for i in range(abs(diff)):
			var new_monster: TrainMonsterOption = TRAIN_MONSTER_OPTION.instantiate()
			_monsters_parent.add_child(new_monster)
			_monsters_displayed.append(new_monster)
	elif diff > 0:
		for i in range(to_display_length, enclosure.active_enclosure.max_capacity + 1):
			_monsters_displayed[i].visible = false
	
	for i in range(to_display_length):
		_monsters_displayed[i].setup(monsters_to_display[i])
	
