class_name Duck
extends CharacterBody2D

var _grid_square := 48
var _fruits_eaten := 0
var _duck_type : DuckTypes = null

@onready var move_timer : Timer = $MoveTimer
@onready var base_duck_sprite : AnimatedSprite2D = $BaseDuckSprite

func _ready() -> void:
	print(_duck_type.name)
	base_duck_sprite.modulate = Color(_duck_type.color)
	
	if _duck_type.is_fast_type:
		move_timer.wait_time = randf_range(1, 2)
	else:
		move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()


func _physics_process(delta: float) -> void:
	if _fruits_eaten == _duck_type.max_fruits:
		velocity.x = 15000 * delta
		move_and_slide()


func load_type(new_duck_type : DuckTypes) -> void:
	_duck_type = new_duck_type
	
	
func eat_fruit() -> bool: # Returns whether Fruit is sucessfully Eaten
	if _fruits_eaten < _duck_type.max_fruits:
		move_timer.stop()
		base_duck_sprite.play("eating")
		return true
		
	else:
		return false
	

func _on_move_timer_timeout() -> void:
	var new_position := Vector2(global_position.x - _grid_square, global_position.y)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position",new_position, 0.6).set_ease(Tween.EASE_OUT)
	if _duck_type.is_fast_type:
		move_timer.wait_time = randf_range(1, 2)
	else:
		move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()


func _on_base_duck_sprite_animation_finished() -> void:
	if base_duck_sprite.animation == "eating":
		_fruits_eaten += 1
		base_duck_sprite.play("default")
		
		if _fruits_eaten == _duck_type.max_fruits:
			base_duck_sprite.flip_h = not base_duck_sprite.flip_h
		else:
			move_timer.start()
