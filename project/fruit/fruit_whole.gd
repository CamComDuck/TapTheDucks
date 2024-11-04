class_name FruitWhole
extends Area2D

func _physics_process(delta: float) -> void:
	global_position.x += 150 * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "LaneBarrierRight":
		ResourceTracker.lives -= 1
		AudioController.play_sound_life_lost()
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Duck:
		var is_eaten : bool = body.eat_fruit()
		if is_eaten:
			AudioController.play_sound_fruit_eat()
			queue_free()
