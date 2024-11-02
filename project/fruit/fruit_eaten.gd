class_name FruitEaten
extends Area2D

func _physics_process(delta: float) -> void:
	global_position.x -= 150 * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "LaneBarrierLeft":
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Player:
		AudioController.play_sound_fruit_pickup()
		ResourceTracker.points += 50
		queue_free()
