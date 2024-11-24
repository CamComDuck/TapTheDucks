@icon("res://ice/ice.png")
class_name Ice
extends Area2D

signal ducks_frozen
signal points_gained (points : int)

@onready var time_until_despawn := $TimeUntilDespawn as Timer

func _ready() -> void:
	time_until_despawn.start()


func on_game_paused(is_paused : bool) -> void:
	time_until_despawn.paused = is_paused
	

func _on_time_until_despawn_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Goose:
		ducks_frozen.emit(global_position)
		points_gained.emit(1500)
		queue_free()
