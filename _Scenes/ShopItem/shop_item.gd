class_name ShopItem
extends Panel

var _icon: TextureRect
var _display_name: Label
var _price: Label
var _is_setup: bool = false

var monster: BaseMonster

func setup_item(new_monster: BaseMonster) -> void:
	if !_is_setup:
		_icon = $Icon
		_display_name = $DisplayName
		_price = $Price
		
		_is_setup = true

	monster = new_monster

	_icon.texture = monster.sprite
	
	var scale_width: int = get_parent().size.x - _icon.size.x
	
	_display_name.add_theme_font_size_override("font_size", floori(scale_width / 7))
	_display_name.text = monster.display_name
	
	var place_groups: int = ceili(float(monster.price.length()) / 3) - 2
	var price_suffix: String = Utils.NUMBER_SUFFIXES.find_key(place_groups) if place_groups >= 0 else ""
	_price.add_theme_font_size_override("font_size", floori(scale_width / 8.5))
	_price.text = "$%s%s" % [monster.price, price_suffix]
