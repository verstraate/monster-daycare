@icon("res://Assets/Sprites/money.png")
class_name BaseMonster
extends Resource

@export var id: String
@export var display_name: String
@export var sprite: Texture2D
@export var base_produce: String
@export var base_upgrade: String
@export var base_upgrade_multiplier: float
@export var type: Utils.MONSTER_TYPES
