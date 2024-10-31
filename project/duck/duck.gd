class_name Duck
extends CharacterBody2D

var _grid_square := 50
var _is_fast_type : bool
var _is_full := false

@onready var move_timer : Timer = $MoveTimer
@onready var base_duck_sprite : AnimatedSprite2D = $BaseDuckSprite
@onready var full_timer_testing : Timer = $FullTimerTESTING

func _physics_process(delta: float) -> void:
	if _is_full:
		velocity.x = 15000 * delta
		move_and_slide()


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


func _on_full_timer_testing_timeout() -> void:
	# Replace with counting hunger to turn is_full to true
	
	pass
	#_is_full = true
	#move_timer.stop()
	#base_duck_sprite.flip_h = not base_duck_sprite.flip_h
