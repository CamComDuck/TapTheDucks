@icon("res://fruit/graphics/fruit_eaten.png")
class_name FruitEaten
extends Area2D

signal life_lost
signal points_gained (points : int)

var in_tree_left_lane : bool

@onready var animation_player := $AnimationPlayer as AnimationPlayer

func _physics_process(delta: float) -> void:
	var move_speed := 200
	if not GameInfo.system_paused and not GameInfo.player_paused:
		if in_tree_left_lane:
			global_position.x -= move_speed * delta
		else:
			global_position.x += move_speed * delta


func on_game_paused(is_paused : bool) -> void:
	if is_paused:
		animation_player.pause()
	else:
		animation_player.play()


func _on_area_entered(area: Area2D) -> void:
	if area is LaneEndGooseSide:
		life_lost.emit(global_position)
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Goose:
		AudioController.play_sound_fruit_pickup()
		points_gained.emit(50)
		queue_free()
