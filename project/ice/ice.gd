class_name Ice
extends Area2D

signal ducks_frozen

@onready var time_until_despawn: Timer = $TimeUntilDespawn

func _ready() -> void:
	time_until_despawn.start()

func _on_time_until_despawn_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		ducks_frozen.emit()
		queue_free()
