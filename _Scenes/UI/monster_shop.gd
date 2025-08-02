class_name MonsterShop
extends Panel

@onready
var monster_parent: BoxContainer = $Monsters
const SHOP_ITEM = preload("res://_Scenes/ShopItem/shop_item.tscn")

@export var monsters_for_sale: Array[BaseMonster] = []
signal shop_updated(monsters_changed: Array[BaseMonster])

var _monsters: Dictionary = {}

func _ready() -> void:
	shop_updated.connect(_display_monsters)	
	_display_monsters(monsters_for_sale)

func add_monsters_to_shop(new_monsters: Array[BaseMonster]) -> void:
	monsters_for_sale.append_array(new_monsters)
	shop_updated.emit(new_monsters)

func update_monsters(monsters_to_update: Dictionary):
	for monster in monsters_to_update:
		var curr_monster: ShopItem = _monsters[monster]
		curr_monster.price = monsters_to_update[monster]
		curr_monster.price_label.text = "$%s" % curr_monster.price.display_value(2)

func _display_monsters(monsters: Array[BaseMonster]) -> void:
	for monster in monsters:
		if _monsters.has(monster.id):
			continue
		
		var monster_shop_item: ShopItem = SHOP_ITEM.instantiate()
		monster_parent.add_child(monster_shop_item)
		monster_shop_item.setup_item(monster)
		_monsters[monster.id] = monster_shop_item
	
