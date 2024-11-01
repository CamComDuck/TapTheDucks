class_name FruitEaten
extends Area2D


func _on_body_entered(body: Node) -> void:
	if body is Player:
		AudioController.play_sound_fruit_pickup()
		queue_free()
