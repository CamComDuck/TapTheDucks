class_name Duck
extends CharacterBody2D

var _grid_square := 50
var _is_fast_type : bool

@onready var move_timer: Timer = $MoveTimer

func print_name(new_name : String):
	print(new_name)


func _on_move_timer_timeout() -> void:
	var new_position := Vector2(global_position.x - _grid_square, global_position.y)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position",new_position, 0.6).set_ease(Tween.EASE_OUT)
	if _is_fast_type:
		move_timer.wait_time = randf_range(1, 2)
	else:
		move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()
