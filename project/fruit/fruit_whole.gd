class_name FruitWhole
extends Area2D

signal life_lost

func _physics_process(delta: float) -> void:
	if Counters.lives > 0:
		global_position.x += 150 * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "LaneBarrierRight":
		life_lost.emit()
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Duck:
		var bodies : Array[Node2D] = get_overlapping_bodies()
		
		if body == bodies[0]:
			var is_eaten : bool = bodies[0].eat_fruit()
			if is_eaten:
				AudioController.play_sound_fruit_eat()
				queue_free()
