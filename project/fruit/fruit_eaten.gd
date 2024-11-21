@icon("res://fruit/graphics/fruit_eaten.png")
class_name FruitEaten
extends Area2D

signal life_lost
signal points_gained (points : int)

var in_tree_left_lane : bool

func _physics_process(delta: float) -> void:
	if not GameInfo.game_paused:
		if in_tree_left_lane:
			global_position.x -= 150 * delta
		else:
			global_position.x += 150 * delta


func _on_area_entered(area: Area2D) -> void:
	if area is LaneEndGooseSide:
		life_lost.emit(global_position)
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Goose:
		AudioController.play_sound_fruit_pickup()
		points_gained.emit(50)
		queue_free()
