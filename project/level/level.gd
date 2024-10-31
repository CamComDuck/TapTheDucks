extends Node2D

var _player_positions : Array[Marker2D] = []
var _duck_positions : Array[Marker2D] = []

var _duck_spawn_min_sec := 2
var _duck_spawn_max_sec := 4

var _round_max_ducks := 10
var _round_current_ducks := 0

var _percent_chance_basic_duck := 40
var _percent_chance_fast_duck := 30
var _percent_chance_hungry_duck := 20

@onready var player_position_1 : Marker2D = $PlayerPosition1
@onready var player_position_2 : Marker2D = $PlayerPosition2
@onready var player_position_3 : Marker2D = $PlayerPosition3
@onready var player_position_4 : Marker2D = $PlayerPosition4
@onready var player : Player = $Player

@onready var duck_position_1 : Marker2D = $DuckPosition1
@onready var duck_position_2 : Marker2D = $DuckPosition2
@onready var duck_position_3 : Marker2D = $DuckPosition3
@onready var duck_position_4 : Marker2D = $DuckPosition4

@onready var duck_spawn_timer : Timer = $DuckSpawnTimer

func _ready() -> void:
	_player_positions.append(player_position_1)
	_player_positions.append(player_position_2)
	_player_positions.append(player_position_3)
	_player_positions.append(player_position_4)
	
	_duck_positions.append(duck_position_1)
	_duck_positions.append(duck_position_2)
	_duck_positions.append(duck_position_3)
	_duck_positions.append(duck_position_4)
	
	player.global_position = _player_positions[0].global_position
	
	duck_spawn_timer.wait_time = randf_range(_duck_spawn_min_sec, _duck_spawn_max_sec)
	duck_spawn_timer.start()
		
		
func _spawn_duck() -> void:
	var new_duck_lane := randi_range(0, 3)
	var new_duck : Duck = load("res://duck/duck.tscn").instantiate()
	var new_duck_type := randi_range(1, 100)
	
	
	if new_duck_type <= _percent_chance_basic_duck:
		# Spawn Basic Duck
		new_duck.set_script(load("res://duck/duck_basic.gd"))
	elif new_duck_type <= (_percent_chance_basic_duck + _percent_chance_fast_duck):
		# Spawn Fast Duck
		new_duck.set_script(load("res://duck/duck_fast.gd"))
	elif new_duck_type <= (_percent_chance_basic_duck + _percent_chance_fast_duck + _percent_chance_hungry_duck):
		# Spawn Hungry Duck
		new_duck.set_script(load("res://duck/duck_hungry.gd"))
	else:
		# Spawn Angry Duck
		new_duck.set_script(load("res://duck/duck_angry.gd"))
	get_parent().add_child.call_deferred(new_duck)
	new_duck.global_position = _duck_positions[new_duck_lane].global_position


func _on_player_lane_changed(new_lane: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position",_player_positions[new_lane - 1].global_position, 0.1).set_ease(Tween.EASE_OUT)
	

func _on_lane_barrier_left_body_entered(body: Node2D) -> void:
	if body is Duck:
		body.queue_free()


func _on_lane_barrier_right_body_entered(body: Node2D) -> void:
	if body is Duck:
		body.queue_free()


func _on_duck_spawn_timer_timeout() -> void:
	_spawn_duck()
	_round_current_ducks += 1
	if _round_current_ducks < _round_max_ducks:
		duck_spawn_timer.wait_time = randf_range(_duck_spawn_min_sec, _duck_spawn_max_sec)
		duck_spawn_timer.start()
	else:
		duck_spawn_timer.stop()
