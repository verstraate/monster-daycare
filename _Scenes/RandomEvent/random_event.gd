class_name RandomEvent extends Control

@onready var despawn_timer: Timer = $Despawn
@onready var event_button: TextureButton = $EventButton

@export_group("Event settings")
@export_subgroup("Reward settings")
@export_range(1.0, 5.0, 0.1) var min_reward_multiplier: float = 1.0
@export_range(1.0, 50.0, 0.1) var max_reward_multiplier: float = 2.0
@export_subgroup("Duration settings")
@export_range(5.0, 30.0, 0.1) var min_reward_duration: float = 5.0
@export_range(5.0, 300.0, 0.1) var max_reward_duration: float = 15.0

@export_group("Shrink settings")
@export_range(0.0, 30.0, 0.1) var time_to_despawn: float = 10.0
@export_range(0.0, 10.0, 0.1) var time_to_shrink: float = 3.0

func _ready() -> void:
	despawn_timer.start(time_to_despawn - time_to_shrink)

func _on_button_pressed() -> void:
	var reward_multiplier: float = Utils.rng.randf_range(min_reward_multiplier, max_reward_multiplier)
	var event_run_time: float = Utils.rng.randf_range(min_reward_duration, max_reward_duration)
	Globals.money_manager.start_currency_event(reward_multiplier, event_run_time)
	queue_free()

func _on_despawn_timeout() -> void:
	var shrink: Tween = get_tree().create_tween()
	shrink.tween_property(
		event_button,
		"scale",
		Vector2.ZERO,
		time_to_shrink
	)
	
	await shrink.finished
	queue_free()
