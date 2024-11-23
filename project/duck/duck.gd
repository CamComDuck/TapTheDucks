@icon("res://duck/graphics/default_1.png")
class_name Duck
extends CharacterBody2D

signal points_gained (points : int)
signal eaten_fruit_spawned (fruit_position : Vector2, lane_number : int)
signal ice_spawned (ice_position : Vector2)

var _fruits_eaten := 0
var _duck_type : DuckTypes = null
var _tween : Tween = null
var _can_move := true

var in_tree_left_lane : bool
var lane_number : int

@onready var move_timer := $MoveTimer as Timer
@onready var base_duck_sprite := $BaseDuckSprite as AnimatedSprite2D

func _ready() -> void:
	base_duck_sprite.modulate = Color(_duck_type.color)
	if not in_tree_left_lane:
		base_duck_sprite.flip_h = not base_duck_sprite.flip_h
	
	if _duck_type.is_fast_type:
		move_timer.wait_time = randf_range(1, 2)
	else:
		move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()


func _physics_process(delta: float) -> void:
	
	if GameInfo.system_paused:
		move_timer.stop()
		velocity.x = 0
		base_duck_sprite.stop()
	
	elif not _can_move:
		pass
	
	elif in_tree_left_lane:
		if _fruits_eaten == _duck_type.max_fruits or (base_duck_sprite.animation == "eating" and position.x < (GameInfo.grid_square_length * 14.5)):
			velocity.x = 15000 * delta
			move_and_slide()
		elif base_duck_sprite.animation == "eating" and position.x >= (GameInfo.grid_square_length * 14.5):
			position.x = minf(position.x, GameInfo.grid_square_length * 14.5)
			
	elif not in_tree_left_lane:
		if _fruits_eaten == _duck_type.max_fruits or (base_duck_sprite.animation == "eating" and position.x > (GameInfo.grid_square_length * 1.5)):
			velocity.x = -15000 * delta
			move_and_slide()
		elif base_duck_sprite.animation == "eating" and position.x <= (GameInfo.grid_square_length * 1.5):
			position.x = maxf(position.x, GameInfo.grid_square_length * 1.5)


func load_type(new_duck_type : DuckTypes) -> void:
	_duck_type = new_duck_type
	
	
func eat_fruit() -> bool: # Returns whether Fruit is sucessfully Eaten
	if _fruits_eaten < _duck_type.max_fruits:
		move_timer.stop()
		_fruits_eaten += 1
		if _tween != null:
			_tween.kill()
		
		var ice_chance := randf_range(1, 10)
		if ice_chance < 10:
			var ice_position := Vector2(global_position.x, global_position.y + 7)
			ice_spawned.emit(ice_position)
		
		base_duck_sprite.play("eating")
		base_duck_sprite.flip_h = not base_duck_sprite.flip_h
		if _fruits_eaten == _duck_type.max_fruits:
			points_gained.emit(_duck_type.point_value)
		return true
		
	else:
		return false
	

func toggle_frozen(is_frozen : bool) -> void:
	if is_frozen:
		base_duck_sprite.modulate = Color(Color.AQUA)
		move_timer.stop()
		base_duck_sprite.stop()
		if _tween != null:
			_tween.kill()
	else:
		base_duck_sprite.modulate = Color(_duck_type.color)
		if base_duck_sprite.animation != "eating":
			move_timer.start()
		base_duck_sprite.play()


func on_game_paused(is_paused : bool) -> void:
	_can_move = not is_paused
	
	if is_paused:
		base_duck_sprite.pause()
		if _tween != null:
			_tween.pause()
	else:
		base_duck_sprite.play()
		if _tween != null:
			if _tween.is_valid():
				_tween.play()
		
	if _fruits_eaten < _duck_type.max_fruits:
		move_timer.paused = is_paused
	else:
		velocity.x = 0
	

func _on_move_timer_timeout() -> void:
	var new_position : Vector2
	
	if in_tree_left_lane:
		new_position = Vector2(global_position.x - GameInfo.grid_square_length, global_position.y)
	else:
		new_position = Vector2(global_position.x + GameInfo.grid_square_length, global_position.y)
	
	_tween = get_tree().create_tween()
	_tween.tween_property(self, "global_position",new_position, 0.6).set_ease(Tween.EASE_OUT)
	
	if _duck_type.is_fast_type:
		move_timer.wait_time = randf_range(1, 2)
	else:
		move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()


func _on_base_duck_sprite_animation_finished() -> void:
	if base_duck_sprite.animation == "eating" and not GameInfo.system_paused:
		base_duck_sprite.play("default")
		
		var fruit_position := Vector2(global_position.x, global_position.y + 7)
		eaten_fruit_spawned.emit(fruit_position, lane_number)
		
		if _fruits_eaten != _duck_type.max_fruits:
			base_duck_sprite.flip_h = not base_duck_sprite.flip_h
			move_timer.start()
			AudioController.play_sound_duck_eat_unfinished()
