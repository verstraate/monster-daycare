class_name MonsterShop
extends Panel

@onready
var monster_parent: BoxContainer = $Monsters
const SHOP_ITEM = preload("res://_Scenes/ShopItem/shop_item.tscn")

@export var monsters_for_sale: Array[BaseMonster] = []
signal shop_updated(monsters_changed: Array[BaseMonster])

var monsters_displayed: Dictionary = {}

func _ready() -> void:
	shop_updated.connect(_display_monsters)
	_display_monsters(monsters_for_sale)

func clear_monsters() -> void:
	print("clear")
	monsters_for_sale.clear()
	for monster in monsters_displayed:
		monsters_displayed[monster].queue_free()
	monsters_displayed.clear()

func add_monsters_to_shop(new_monsters: Array[BaseMonster]) -> void:
	print("add")
	monsters_for_sale.append_array(new_monsters)
	shop_updated.emit(new_monsters)

func _display_monsters(monsters: Array[BaseMonster]) -> void:
	for monster in monsters:
		if monsters_displayed.has(monster.id):
			continue
		
		var monster_shop_item: ShopItem = SHOP_ITEM.instantiate()
		monster_parent.add_child(monster_shop_item)
		monster_shop_item.setup_item(monster)
		monsters_displayed[monster.id] = monster_shop_item

func save() -> Dictionary:
	var monsters_to_save: Dictionary
	for item in monsters_displayed.keys():
		var curr_monster: ShopItem = monsters_displayed[item]
		monsters_to_save[item] = {
			"data": curr_monster.monster.resource_path,
			"price": curr_monster.price.array_to_num()
		}
	
	return {
		"path": get_path(),
		"monsters_for_sale": monsters_to_save,
	}
