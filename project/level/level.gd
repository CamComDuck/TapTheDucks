extends Node2D

var _player_positions : Array[Marker2D] = []
var _duck_positions : Array[Marker2D] = []
var _lane_endings_player_side : Array[Area2D] = []
var _lane_endings_duck_side : Array[Area2D] = []
var _player_current_lane : int
var _background : TileMapLayer = null

var _duck_spawn_min_sec := 2
var _duck_spawn_max_sec := 4

var _current_points := 0
var _current_round := 1
var _round_max_ducks := 10
var _round_current_ducks := 0
var _ducks_finished := 0

var _current_lanes_tree_left : Array = [true, true, true, true]

var _duck_y_addition := 17
var _lane_positions : Dictionary = {
	"player_x_left" : 168,
	"player_x_right" : 600,
	"duck_x_left" : 72,
	"duck_x_right" : 696,
	"y_lanes" : [144, 288, 432, 576]
}

var _percent_chance_basic_duck := 40
var _percent_chance_fast_duck := 30
var _percent_chance_hungry_duck := 20

var _allow_input := true

@onready var game_overlay := $GameOverlay as GameOverlay
@onready var duck_spawn_timer := $DuckSpawnTimer as Timer

@onready var player_position_1 := $PlayerPosition1 as Marker2D
@onready var player_position_2 := $PlayerPosition2 as Marker2D
@onready var player_position_3 := $PlayerPosition3 as Marker2D
@onready var player_position_4 := $PlayerPosition4 as Marker2D
@onready var player := $Player as Player

@onready var duck_position_1 := $DuckPosition1 as Marker2D
@onready var duck_position_2 := $DuckPosition2 as Marker2D
@onready var duck_position_3 := $DuckPosition3 as Marker2D
@onready var duck_position_4 := $DuckPosition4 as Marker2D

@onready var duck : = load("res://duck/duck.tscn") as PackedScene
@onready var duck_basic := load("res://duck/duck_types/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/duck_types/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/duck_types/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/duck_types/duck_angry.tres") as DuckTypes

@onready var lane_end_player_side_1 := $LaneEndPlayerSide1 as LaneEndPlayerSide
@onready var lane_end_player_side_2 := $LaneEndPlayerSide2 as LaneEndPlayerSide
@onready var lane_end_player_side_3 := $LaneEndPlayerSide3 as LaneEndPlayerSide
@onready var lane_end_player_side_4 := $LaneEndPlayerSide4 as LaneEndPlayerSide
@onready var lane_end_duck_side_1 := $LaneEndDuckSide1 as LaneEndDuckSide
@onready var lane_end_duck_side_2 := $LaneEndDuckSide2 as LaneEndDuckSide
@onready var lane_end_duck_side_3 := $LaneEndDuckSide3 as LaneEndDuckSide
@onready var lane_end_duck_side_4 := $LaneEndDuckSide4 as LaneEndDuckSide

@onready var fruit_whole := load("res://fruit/fruit_whole.tscn") as PackedScene
@onready var eaten_fruit := load("res://fruit/fruit_eaten.tscn") as PackedScene

@onready var map_1 := load("res://level/map_types/resources/map_1.tres") as MapTypes
@onready var map_1_background := load("res://level/map_types/backgrounds/bg_map_1.tscn") as PackedScene
@onready var map_2 := load("res://level/map_types/resources/map_2.tres") as MapTypes
@onready var map_2_background := load("res://level/map_types/backgrounds/bg_map_2.tscn") as PackedScene
@onready var map_3 := load("res://level/map_types/resources/map_3.tres") as MapTypes
@onready var map_3_background := load("res://level/map_types/backgrounds/bg_map_3.tscn") as PackedScene
@onready var map_4 := load("res://level/map_types/resources/map_4.tres") as MapTypes
@onready var map_4_background := load("res://level/map_types/backgrounds/bg_map_4.tscn") as PackedScene


func _ready() -> void:
	_player_positions.append(player_position_1)
	_player_positions.append(player_position_2)
	_player_positions.append(player_position_3)
	_player_positions.append(player_position_4)
	
	_duck_positions.append(duck_position_1)
	_duck_positions.append(duck_position_2)
	_duck_positions.append(duck_position_3)
	_duck_positions.append(duck_position_4)
	
	_lane_endings_player_side.append(lane_end_player_side_1)
	_lane_endings_player_side.append(lane_end_player_side_2)
	_lane_endings_player_side.append(lane_end_player_side_3)
	_lane_endings_player_side.append(lane_end_player_side_4)
	
	_lane_endings_duck_side.append(lane_end_duck_side_1)
	_lane_endings_duck_side.append(lane_end_duck_side_2)
	_lane_endings_duck_side.append(lane_end_duck_side_3)
	_lane_endings_duck_side.append(lane_end_duck_side_4)
	
	_on_round_start()
		
		
func _physics_process(_delta: float) -> void:
	if not _allow_input:
		pass
		
	elif Input.is_action_just_pressed("move_down"):
		_allow_input = false
		_player_current_lane += 1
		if _player_current_lane == 4:
			_player_current_lane = 0
		AudioController.play_sound_player_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
	
	elif Input.is_action_just_pressed("move_up"):
		_allow_input = false
		_player_current_lane -= 1
		if _player_current_lane == -1:
			_player_current_lane = 3
		AudioController.play_sound_player_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
		
	elif Counters.player_on_left:
		if Input.is_action_pressed("interact_right") and player.position.x < Counters.grid_square_length * 14.5:
			player.velocity.x = 150
			player.move_and_slide()
			
		elif Input.is_action_just_released("interact_right"):
			_allow_input = false
			var tween : Tween = get_tree().create_tween()
			tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
			await tween.finished
			_allow_input = true
			
		elif Input.is_action_just_pressed("interact_left"):
			_allow_input = false
			player.play_animation("fruit_pick")
			
			await player.animation_finished
			
			var new_fruit_whole := fruit_whole.instantiate() as FruitWhole
			add_child.call_deferred(new_fruit_whole)
			new_fruit_whole.global_position.x = _player_positions[_player_current_lane].global_position.x + Counters.grid_square_length
			new_fruit_whole.global_position.y = _player_positions[_player_current_lane].global_position.y + (Counters.grid_square_length / 2.0)
			_allow_input = true
		
	elif not Counters.player_on_left:
		
		if Input.is_action_pressed("interact_left") and player.position.x > Counters.grid_square_length * 1.5:
			player.velocity.x = -150
			player.move_and_slide()
			
		elif Input.is_action_just_released("interact_left"):
			_allow_input = false
			var tween : Tween = get_tree().create_tween()
			tween.tween_property(player, "global_position",_player_positions[_player_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
			await tween.finished
			_allow_input = true
			
		elif Input.is_action_just_pressed("interact_right"):
			_allow_input = false
			player.play_animation("fruit_pick")
			
			await player.animation_finished
			
			var new_fruit_whole := fruit_whole.instantiate() as FruitWhole
			add_child.call_deferred(new_fruit_whole)
			new_fruit_whole.global_position.x = _player_positions[_player_current_lane].global_position.x - Counters.grid_square_length
			new_fruit_whole.global_position.y = _player_positions[_player_current_lane].global_position.y + (Counters.grid_square_length / 2.0)
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
	
	add_child.call_deferred(new_duck)
	new_duck.global_position = _duck_positions[new_duck_lane].global_position


func _on_life_lost() -> void:
	if not Counters.game_end:
		Counters.lives -= 1
		game_overlay.update_lives_label()
		AudioController.play_sound_life_lost()
		
		if Counters.lives == 0:
			AudioController.play_sound_lose()
			_allow_input = false
			game_overlay.game_end(false)
			duck_spawn_timer.stop()
			Counters.game_end = true
			

func _on_points_gained(points : int) -> void:
	_current_points += points
	game_overlay.update_points_label(_current_points)
	

func _on_eaten_fruit_spawned(fruit_position : Vector2) -> void:
	var new_eaten_fruit := eaten_fruit.instantiate() as FruitEaten
	add_child.call_deferred(new_eaten_fruit)
	new_eaten_fruit.global_position = fruit_position
	

func _on_round_start() -> void:
	var current_map_type : MapTypes
		
	if _current_round % 4 == 1:
		current_map_type = map_1
		
		if _background != null:
			_background.queue_free()
			
		_background = map_1_background.instantiate() as TileMapLayer
		
	elif _current_round % 4 == 2:
		current_map_type = map_2
		_background = map_2_background.instantiate() as TileMapLayer
		
	elif _current_round % 4 == 3:
		current_map_type = map_3
		_background = map_3_background.instantiate() as TileMapLayer
		
	elif _current_round % 4 == 0:
		current_map_type = map_4
		_background = map_4_background.instantiate() as TileMapLayer
	
	
	for i in 4:
		_current_lanes_tree_left[i] = current_map_type.lane_is_left_tree[i]
		
		if _current_lanes_tree_left[i]:
			_player_positions[i].global_position.x = _lane_positions["player_x_left"]
			_player_positions[i].global_position.y = _lane_positions["y_lanes"][i]
			_duck_positions[i].global_position.x = _lane_positions["duck_x_right"]
			_duck_positions[i].global_position.y = _lane_positions["y_lanes"][i] + _duck_y_addition
			_lane_endings_duck_side[i].global_position.x = _duck_positions[i].global_position.x + Counters.grid_square_length
			_lane_endings_duck_side[i].global_position.y = _duck_positions[i].global_position.y
		
		else:
			_player_positions[i].global_position.x = _lane_positions["player_x_right"]
			_player_positions[i].global_position.y = _lane_positions["y_lanes"][i]
			_duck_positions[i].global_position.x = _lane_positions["duck_x_left"]
			_duck_positions[i].global_position.y = _lane_positions["y_lanes"][i] + _duck_y_addition
			_lane_endings_duck_side[i].global_position.x = _duck_positions[i].global_position.x - Counters.grid_square_length
			_lane_endings_duck_side[i].global_position.y = _duck_positions[i].global_position.y
	
		_lane_endings_player_side[i].global_position = _player_positions[i].global_position
		
	
	add_child.call_deferred(_background)
	game_overlay.update_round_label(_current_round)
	player.global_position = _player_positions[0].global_position
	duck_spawn_timer.wait_time = randf_range(_duck_spawn_min_sec, _duck_spawn_max_sec)
	duck_spawn_timer.start()


func _on_lane_end_player_side_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		_on_life_lost()
		game_overlay.update_lives_label()
		body.queue_free()


func _on_lane_end_duck_side_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		body.queue_free()
		
		if _current_points >= 100 and _ducks_finished == _round_max_ducks:
			_allow_input = false
			game_overlay.game_end(true)
			Counters.game_end = true
			AudioController.play_sound_win()


func _on_duck_spawn_timer_timeout() -> void:
	_spawn_duck()
	_round_current_ducks += 1
	if _round_current_ducks < _round_max_ducks:
		duck_spawn_timer.wait_time = randf_range(_duck_spawn_min_sec, _duck_spawn_max_sec)
		duck_spawn_timer.start()
	else:
		duck_spawn_timer.stop()


func _on_child_entered_tree(node: Node) -> void:
	if node is FruitEaten or node is FruitWhole:
		node.connect("life_lost", _on_life_lost)
		
	if node is FruitEaten or node is Duck:
		node.connect("points_gained", _on_points_gained)
	
	if node is Duck:
		node.connect("eaten_fruit_spawned", _on_eaten_fruit_spawned)
