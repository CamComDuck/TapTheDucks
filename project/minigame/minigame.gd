extends Node2D

signal minigame_finished (points_earned : int)


func _on_button_testing_pressed() -> void:
	minigame_finished.emit(50)
	queue_free()
