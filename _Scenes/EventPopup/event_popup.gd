class_name EventPopup extends Button

@onready
var icon_container: Control = $IconContainer

@export_range(2.0, 5.0, 0.1)
var min_multiplier: float = 2.0
@export_range(2.0, 10.0, 0.1)
var max_multiplier: float = 2.0
@export_range(1.0, 20.0, 1.0)
var min_duration: float = 5.0
@export_range(10.0, 300.0, 5.0)
var max_duration: float = 5.0

@export
var shrink_duration: float = 5.0

func _on_event_pressed() -> void:
	var multiplier: float = Utils.rng.randf_range(min_multiplier, max_multiplier)
	var duration: float = Utils.rng.randf_range(min_duration, max_duration)
	SignalBus.event_started.emit(multiplier, duration)
	queue_free()

func _on_despawn_timeout() -> void:
	var shrink: Tween = get_tree().create_tween()
	shrink.set_parallel()
	shrink.tween_property(
		icon_container,
		"scale",
		Vector2.ZERO,
		shrink_duration
	)
	
	await shrink.finished
	queue_free()
