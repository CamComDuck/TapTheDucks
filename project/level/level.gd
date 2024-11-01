extends Node2D

var _player_positions : Array[Marker2D] = []
var _duck_positions : Array[Marker2D] = []
var _player_current_lane : int

var _duck_spawn_min_sec := 2
var _duck_spawn_max_sec := 4

var _round_max_ducks := 10
var _round_current_ducks := 0

var _percent_chance_basic_duck := 40
var _percent_chance_fast_duck := 30
var _percent_chance_hungry_duck := 20

var _can_pick_fruit := true

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

@onready var duck : PackedScene = load("res://duck/duck.tscn")
@onready var fruit_whole : PackedScene = load("res://fruit/fruit_whole.tscn")

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
		
		
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact_left") and _can_pick_fruit and not (Input.is_action_pressed("interact_right") or Input.is_action_pressed("move_down") or Input.is_action_pressed("move_up")):
		_can_pick_fruit = false
		player.play_animation("fruit_pick")
		
		await player.animation_finished
		
		var new_fruit_whole := fruit_whole.instantiate() as FruitWhole
		get_parent().add_child.call_deferred(new_fruit_whole)
		new_fruit_whole.global_position.x = _player_positions[_player_current_lane].global_position.x + 48
		new_fruit_whole.global_position.y = _player_positions[_player_current_lane].global_position.y + 24
		_can_pick_fruit = true
		
		
func _spawn_duck() -> void:
	var new_duck_lane := randi_range(0, 3)
	var chosen_type : DuckTypes
	var random_type_roll := randi_range(1, 100)
	
	
	if random_type_roll <= _percent_chance_basic_duck:
		# Spawn Basic Duck
		chosen_type = load("res://duck/resources/duck_basic.tres") as DuckTypes 
		
	elif random_type_roll <= (_percent_chance_basic_duck + _percent_chance_fast_duck):
		# Spawn Fast Duck
		chosen_type = load("res://duck/resources/duck_fast.tres") as DuckTypes 
		
	elif random_type_roll <= (_percent_chance_basic_duck + _percent_chance_fast_duck + _percent_chance_hungry_duck):
		# Spawn Hungry Duck
		chosen_type = load("res://duck/resources/duck_hungry.tres") as DuckTypes 
		
	else:
		# Spawn Angry Duck
		chosen_type = load("res://duck/resources/duck_angry.tres") as DuckTypes 
		
	var new_duck := duck.instantiate() as Duck
	new_duck.load_type(chosen_type)
	get_parent().add_child.call_deferred(new_duck)
	new_duck.global_position = _duck_positions[new_duck_lane].global_position


func _on_player_lane_changed(new_lane: int) -> void:
	_player_current_lane = new_lane - 1
	var tween = get_tree().create_tween()
	tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
	

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
