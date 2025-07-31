class_name MonsterShop
extends Panel

@onready
var monster_parent: BoxContainer = $Monsters
const SHOP_ITEM = preload("res://_Scenes/ShopItem/shop_item.tscn")

@export var monsters_for_sale: Array[BaseMonster] = []
signal shop_updated(monsters_changed: Array[BaseMonster])

func _ready() -> void:
	shop_updated.connect(_display_monsters)	
	_display_monsters(monsters_for_sale)

func add_monsters_to_shop(new_monsters: Array[BaseMonster]) -> void:
	monsters_for_sale.append_array(new_monsters)
	shop_updated.emit(new_monsters)

func _display_monsters(monsters_changed: Array[BaseMonster]) -> void:
	if monster_parent.get_child_count() != monsters_for_sale.size():
		for monster in monsters_changed:
			var monster_shop_item: ShopItem = SHOP_ITEM.instantiate()
			monster_parent.add_child(monster_shop_item)
			monster_shop_item.setup_item(monster)
