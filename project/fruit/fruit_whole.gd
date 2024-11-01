class_name FruitWhole
extends Area2D


func _physics_process(delta: float) -> void:
	global_position.x += 100 * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "LaneBarrierRight":
		queue_free()
