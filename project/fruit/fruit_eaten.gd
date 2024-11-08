class_name FruitEaten
extends Area2D

signal life_lost
signal points_gained (points : int)

func _physics_process(delta: float) -> void:
	if not Counters.game_end:
		if Counters.player_on_left:
			global_position.x -= 150 * delta
		else:
			global_position.x += 150 * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "LaneEndPlayerSide":
		life_lost.emit()
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Player:
		AudioController.play_sound_fruit_pickup()
		points_gained.emit(50)
		queue_free()
