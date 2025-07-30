class_name ShopItem
extends Button

var _money_manager: MoneyManager
var _enclosure_manager: EnclosureManager
const MONSTER = preload("res://_Scenes/Monster/monster.tscn")

var _icon: TextureRect
var _display_name: Label
var _price_label: Label
var _is_setup: bool = false

var monster: BaseMonster
var price: IdleNumber

func setup_item(new_monster: BaseMonster) -> void:
	if !_is_setup:
		_money_manager = get_tree().get_first_node_in_group("Money") as MoneyManager
		_enclosure_manager = get_tree().get_first_node_in_group("Enclosures") as EnclosureManager
		
		_icon = $Icon
		_display_name = $DisplayName
		_price_label = $Price
		
		_is_setup = true

	monster = new_monster

	price = IdleNumber.new(monster.price)
	_icon.texture = monster.sprite
	
	var scale_width: int = get_parent().size.x - _icon.size.x
	
	_display_name.add_theme_font_size_override("font_size", floori(scale_width / 7))
	_display_name.text = monster.display_name
	
	_price_label.add_theme_font_size_override("font_size", floori(scale_width / 8.5))
	_price_label.text = price.display_value(2)

func _on_pressed() -> void:
	var active_enclosure: Enclosure = _enclosure_manager.enclosures[_enclosure_manager.selected_enclosure]
	if active_enclosure.at_max_capacity():
		return
	
	if not _money_manager.try_purchase(monster.price):
		return
	
	var new_monster: Monster = MONSTER.instantiate()
	active_enclosure.try_add_monster(new_monster)
	new_monster.setup_monster(monster)
