class_name FruitEaten
extends Area2D


func _on_body_entered(body: Node) -> void:
	if body is Player:
		queue_free()
