@icon("res://duck/graphics/default_1.png")
class_name Duck
extends CharacterBody2D

signal points_gained (points : int)
signal eaten_fruit_spawned (fruit_position : Vector2, lane_number : int)
signal ice_spawned (ice_position : Vector2)

var _fruits_eaten := 0
var _duck_type : DuckTypes = null
var _tween : Tween = null
var can_eat : bool = true

var in_tree_left_lane : bool
var lane_number : int

@onready var move_timer := %MoveTimer as Timer
@onready var base_duck_sprite := %BaseDuckSprite as AnimatedSprite2D
@onready var state_chart: StateChart = %StateChart

func _ready() -> void:
	base_duck_sprite.modulate = Color(_duck_type.color)
	if not in_tree_left_lane:
		base_duck_sprite.flip_h = not base_duck_sprite.flip_h


func load_type(new_duck_type : DuckTypes) -> void:
	_duck_type = new_duck_type
	

func toggle_frozen(is_frozen : bool) -> void:
	if is_frozen:
		state_chart.send_event("freeze")
		
	else:
		state_chart.send_event("unfreeze")
		

func on_game_paused(is_paused : bool) -> void:
	if is_paused:
		state_chart.send_event("paused")

	else:
		state_chart.send_event("unpaused")
	
	
func _restart_move_timer() -> void:
	if _duck_type.is_fast_type:
		move_timer.wait_time = randf_range(0.7, 0.9)
	else:
		move_timer.wait_time = randf_range(0.9, 1.1)
	move_timer.start()


func _on_move_timer_timeout() -> void:
	var new_position : Vector2
	
	if in_tree_left_lane:
		new_position = Vector2(global_position.x - GameInfo.grid_square_length, global_position.y)
	else:
		new_position = Vector2(global_position.x + GameInfo.grid_square_length, global_position.y)
	
	_tween = get_tree().create_tween()
	_tween.tween_property(self, "global_position",new_position, 0.6).set_ease(Tween.EASE_OUT)
	
	_restart_move_timer()


func _on_base_duck_sprite_animation_finished() -> void:
	base_duck_sprite.play("default")
	
	var fruit_position := Vector2(global_position.x, global_position.y + 7)
	eaten_fruit_spawned.emit(fruit_position, lane_number)
	
	if _fruits_eaten != _duck_type.max_fruits:
		base_duck_sprite.flip_h = not base_duck_sprite.flip_h
		AudioController.play_sound_duck_eat_unfinished()
		state_chart.send_event("hungry")

## Hungry State ##

func _on_hungry_state_entered() -> void:
	can_eat = true
	_restart_move_timer()


func _on_hungry_state_exited() -> void:
	move_timer.stop()
	if _tween != null:
		_tween.pause()
	

func _on_hungry_event_received(event: StringName) -> void:
	if event == "eat_fruit":
		_fruits_eaten += 1
		
		var ice_chance := randf_range(1, 10)
		if ice_chance < 10.5:
			var ice_position := Vector2(global_position.x, global_position.y + 7)
			ice_spawned.emit(ice_position)
		
		base_duck_sprite.play("eating")
		base_duck_sprite.flip_h = not base_duck_sprite.flip_h
		if _fruits_eaten == _duck_type.max_fruits:
			points_gained.emit(_duck_type.point_value)
		state_chart.send_event("eating")

	
## Eating State ##

func _on_eating_state_entered() -> void:
	can_eat = false
	

func _on_eating_state_physics_processing(delta: float) -> void:
	var move_speed := 18500
	
	if in_tree_left_lane:
		if _fruits_eaten == _duck_type.max_fruits or position.x < (GameInfo.grid_square_length * 14.5):
			velocity.x = move_speed * delta
			move_and_slide()
		elif position.x >= (GameInfo.grid_square_length * 14.5):
			position.x = minf(position.x, GameInfo.grid_square_length * 14.5)
			
	elif not in_tree_left_lane:
		if _fruits_eaten == _duck_type.max_fruits or position.x > (GameInfo.grid_square_length * 1.5):
			velocity.x = -1 * move_speed * delta
			move_and_slide()
		elif position.x <= (GameInfo.grid_square_length * 1.5):
			position.x = maxf(position.x, GameInfo.grid_square_length * 1.5)
			

## Frozen State ##

func _on_frozen_state_entered() -> void:
	base_duck_sprite.modulate = Color("7ab1ae")
	if _fruits_eaten < _duck_type.max_fruits:
		can_eat = true
	base_duck_sprite.pause()


func _on_frozen_state_exited() -> void:
	base_duck_sprite.modulate = Color(_duck_type.color)
	base_duck_sprite.play()


func _on_frozen_event_received(event: StringName) -> void:
	if event == "eat_fruit":
		_fruits_eaten += 1
		
		base_duck_sprite.play("eating")
		base_duck_sprite.flip_h = not base_duck_sprite.flip_h
		if _fruits_eaten == _duck_type.max_fruits:
			points_gained.emit(_duck_type.point_value)
		state_chart.send_event("eating")

## Paused State ##

func _on_paused_state_entered() -> void:
	base_duck_sprite.pause()


func _on_paused_state_exited() -> void:
	base_duck_sprite.play()
	if _tween != null:
		if _tween.is_valid():
			_tween.play()
