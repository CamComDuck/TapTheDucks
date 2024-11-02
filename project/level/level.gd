extends Node2D

var _player_positions : Array[Marker2D] = []
var _duck_positions : Array[Marker2D] = []
var _player_current_lane : int

var _duck_spawn_min_sec := 2
var _duck_spawn_max_sec := 4

var _round_max_ducks := 10
var _round_current_ducks := 0
var _ducks_finished := 0

var _percent_chance_basic_duck := 40
var _percent_chance_fast_duck := 30
var _percent_chance_hungry_duck := 20

var _allow_input := true

@onready var game_overlay := $GameOverlay as Control

@onready var player_position_1 := $PlayerPosition1 as Marker2D
@onready var player_position_2 := $PlayerPosition2 as Marker2D
@onready var player_position_3 := $PlayerPosition3 as Marker2D
@onready var player_position_4 := $PlayerPosition4 as Marker2D
@onready var player := $Player as Player

@onready var duck_position_1 := $DuckPosition1 as Marker2D
@onready var duck_position_2 := $DuckPosition2 as Marker2D
@onready var duck_position_3 := $DuckPosition3 as Marker2D
@onready var duck_position_4 := $DuckPosition4 as Marker2D

@onready var duck_spawn_timer := $DuckSpawnTimer as Timer

@onready var duck : = load("res://duck/duck.tscn") as PackedScene
@onready var duck_basic := load("res://duck/resources/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/resources/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/resources/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/resources/duck_angry.tres") as DuckTypes

@onready var fruit_whole := load("res://fruit/fruit_whole.tscn") as PackedScene


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
	if not _allow_input:
		pass
		
	elif Input.is_action_pressed("interact_right") and player.position.x < 696:
		player.velocity.x = 150
		player.move_and_slide()
		
	elif Input.is_action_just_released("interact_right"):
		_allow_input = false
		var tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
		
	elif Input.is_action_just_pressed("move_down"):
		_allow_input = false
		_player_current_lane += 1
		if _player_current_lane == 4:
			_player_current_lane = 0
		AudioController.play_sound_player_move()
		var tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
	
	elif Input.is_action_just_pressed("move_up"):
		_allow_input = false
		_player_current_lane -= 1
		if _player_current_lane == -1:
			_player_current_lane = 3
		AudioController.play_sound_player_move()
		var tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
	
	elif Input.is_action_just_pressed("interact_left"):
		_allow_input = false
		player.play_animation("fruit_pick")
		
		await player.animation_finished
		
		var new_fruit_whole := fruit_whole.instantiate() as FruitWhole
		get_parent().add_child.call_deferred(new_fruit_whole)
		new_fruit_whole.global_position.x = _player_positions[_player_current_lane].global_position.x + 48
		new_fruit_whole.global_position.y = _player_positions[_player_current_lane].global_position.y + 24
		_allow_input = true
		
		
func _spawn_duck() -> void:
	var new_duck_lane := randi_range(0, 3)
	var new_duck := duck.instantiate() as Duck
	var random_type_roll := randi_range(1, 100)
	
	
	if random_type_roll <= _percent_chance_basic_duck:
		# Spawn Basic Duck
		new_duck.load_type(duck_basic)
		
	elif random_type_roll <= (_percent_chance_basic_duck + _percent_chance_fast_duck):
		# Spawn Fast Duck
		new_duck.load_type(duck_fast)
		
	elif random_type_roll <= (_percent_chance_basic_duck + _percent_chance_fast_duck + _percent_chance_hungry_duck):
		# Spawn Hungry Duck
		new_duck.load_type(duck_hungry)
		
	else:
		# Spawn Angry Duck
		new_duck.load_type(duck_angry)
	
	get_parent().add_child.call_deferred(new_duck)
	new_duck.global_position = _duck_positions[new_duck_lane].global_position


func _on_lane_barrier_left_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		body.queue_free()


func _on_lane_barrier_right_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		body.queue_free()
		
		if ResourceTracker.points >= 100 and _ducks_finished == _round_max_ducks:
			_allow_input = false
			game_overlay.game_end(true)


func _on_duck_spawn_timer_timeout() -> void:
	_spawn_duck()
	_round_current_ducks += 1
	if _round_current_ducks < _round_max_ducks:
		duck_spawn_timer.wait_time = randf_range(_duck_spawn_min_sec, _duck_spawn_max_sec)
		duck_spawn_timer.start()
	else:
		duck_spawn_timer.stop()
