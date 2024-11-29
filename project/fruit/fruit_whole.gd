@icon("res://fruit/graphics/fruit_whole.png")
class_name FruitWhole
extends Area2D

signal life_lost

var in_tree_left_lane : bool

@onready var animation_player := $AnimationPlayer as AnimationPlayer

func _physics_process(delta: float) -> void:
	var move_speed := 450
	if not GameInfo.system_paused and not GameInfo.player_paused:
		if in_tree_left_lane:
			global_position.x += move_speed * delta
		else:
			global_position.x -= move_speed * delta

func on_game_paused(is_paused : bool) -> void:
	if is_paused:
		animation_player.pause()
	else:
		animation_player.play()
	

func _on_area_entered(area: Area2D) -> void:
	if area is LaneEndDuckSide:
		life_lost.emit(global_position)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Duck:
		var bodies : Array[Node2D] = get_overlapping_bodies()
		
		if body == bodies[0]:
			var duck := bodies[0] as Duck
			if duck.can_eat:
				AudioController.play_sound_fruit_eat()
				queue_free()
			duck.state_chart.send_event("eat_fruit")
