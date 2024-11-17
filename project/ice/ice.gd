class_name Ice
extends Area2D

@onready var time_until_despawn: Timer = $TimeUntilDespawn

func _ready() -> void:
	time_until_despawn.start()

func _on_time_until_despawn_timeout() -> void:
	queue_free()
