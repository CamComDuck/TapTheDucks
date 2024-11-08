class_name Duck
extends CharacterBody2D

signal points_gained (points : int)
signal eaten_fruit_spawned (fruit_position : Vector2)

var _grid_square := 48
var _fruits_eaten := 0
var _duck_type : DuckTypes = null
var _tween : Tween

@onready var move_timer := $MoveTimer as Timer
@onready var base_duck_sprite := $BaseDuckSprite as AnimatedSprite2D

func _ready() -> void:
	base_duck_sprite.modulate = Color(_duck_type.color)
	
	if _duck_type.is_fast_type:
		move_timer.wait_time = randf_range(1, 2)
	else:
		move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()


func _physics_process(delta: float) -> void:
	if Counters.lives <= 0:
		move_timer.stop()
		velocity.x = 0
		
	elif _fruits_eaten == _duck_type.max_fruits or (base_duck_sprite.animation == "eating" and position.x < 695):
		velocity.x = 15000 * delta
		move_and_slide()


func load_type(new_duck_type : DuckTypes) -> void:
	_duck_type = new_duck_type
	
	
func eat_fruit() -> bool: # Returns whether Fruit is sucessfully Eaten
	if _fruits_eaten < _duck_type.max_fruits:
		move_timer.stop()
		_fruits_eaten += 1
		_tween.kill()
		base_duck_sprite.play("eating")
		if _fruits_eaten == _duck_type.max_fruits:
			points_gained.emit(_duck_type.point_value)
		return true
		
	else:
		return false
	

func _on_move_timer_timeout() -> void:
	var new_position := Vector2(global_position.x - _grid_square, global_position.y)
	_tween = get_tree().create_tween()
	_tween.tween_property(self, "global_position",new_position, 0.6).set_ease(Tween.EASE_OUT)
	if _duck_type.is_fast_type:
		move_timer.wait_time = randf_range(1, 2)
	else:
		move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()


func _on_base_duck_sprite_animation_finished() -> void:
	if base_duck_sprite.animation == "eating":
		base_duck_sprite.play("default")
		
		var fruit_position := Vector2(global_position.x, global_position.y + 7)
		eaten_fruit_spawned.emit(fruit_position)
		
		if _fruits_eaten == _duck_type.max_fruits:
			base_duck_sprite.flip_h = not base_duck_sprite.flip_h
			
		else:
			move_timer.start()
			AudioController.play_sound_duck_eat_unfinished()
