@icon("res://level/graphics/tree.png")
extends Node2D

var _goose_positions : Array[Marker2D] = []
var _duck_positions : Array[Marker2D] = []
var _lane_endings_goose_side : Array[Area2D] = []
var _lane_endings_duck_side : Array[Area2D] = []
var _current_ducks_swimming : Array[Duck] = []
var _goose_current_lane : int
var _background : TileMapLayer = null

var _current_points := 0
var _current_round := 1
var _round_max_ducks := 5
var _round_current_ducks := 0
var _ducks_finished := 0

var _lane_tree_is_left : Array[bool] = [true, true, true, true]

var _allow_input := true

@onready var game_overlay := $GameOverlay as GameOverlay
@onready var duck_spawn_timer := $DuckSpawnTimer as Timer

@onready var goose_position_1 := $GoosePosition1 as Marker2D
@onready var goose_position_2 := $GoosePosition2 as Marker2D
@onready var goose_position_3 := $GoosePosition3 as Marker2D
@onready var goose_position_4 := $GoosePosition4 as Marker2D
@onready var goose := $Goose as Goose

@onready var duck_position_1 := $DuckPosition1 as Marker2D
@onready var duck_position_2 := $DuckPosition2 as Marker2D
@onready var duck_position_3 := $DuckPosition3 as Marker2D
@onready var duck_position_4 := $DuckPosition4 as Marker2D

@onready var duck : = load("res://duck/duck.tscn") as PackedScene
@onready var duck_basic := load("res://duck/duck_types/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/duck_types/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/duck_types/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/duck_types/duck_angry.tres") as DuckTypes

@onready var lane_end_goose_side_1 := $LaneEndGooseSide1 as LaneEndGooseSide
@onready var lane_end_goose_side_2 := $LaneEndGooseSide2 as LaneEndGooseSide
@onready var lane_end_goose_side_3 := $LaneEndGooseSide3 as LaneEndGooseSide
@onready var lane_end_goose_side_4 := $LaneEndGooseSide4 as LaneEndGooseSide
@onready var lane_end_duck_side_1 := $LaneEndDuckSide1 as LaneEndDuckSide
@onready var lane_end_duck_side_2 := $LaneEndDuckSide2 as LaneEndDuckSide
@onready var lane_end_duck_side_3 := $LaneEndDuckSide3 as LaneEndDuckSide
@onready var lane_end_duck_side_4 := $LaneEndDuckSide4 as LaneEndDuckSide

@onready var fruit_whole := load("res://fruit/fruit_whole.tscn") as PackedScene
@onready var eaten_fruit := load("res://fruit/fruit_eaten.tscn") as PackedScene

@onready var ice := load("res://ice/ice.tscn") as PackedScene
@onready var duck_freeze := $DuckFreeze as Timer

@onready var map_1 := load("res://level/map_types/resources/map_1.tres") as MapTypes
@onready var map_1_background := load("res://level/map_types/backgrounds/bg_map_1.tscn") as PackedScene
@onready var map_2 := load("res://level/map_types/resources/map_2.tres") as MapTypes
@onready var map_2_background := load("res://level/map_types/backgrounds/bg_map_2.tscn") as PackedScene
@onready var map_3 := load("res://level/map_types/resources/map_3.tres") as MapTypes
@onready var map_3_background := load("res://level/map_types/backgrounds/bg_map_3.tscn") as PackedScene
@onready var map_4 := load("res://level/map_types/resources/map_4.tres") as MapTypes
@onready var map_4_background := load("res://level/map_types/backgrounds/bg_map_4.tscn") as PackedScene

@onready var minigame := load("res://minigame/minigame.tscn") as PackedScene

@onready var lost_life_particles := load("res://level/lost_life_particles.tscn") as PackedScene
@onready var ice_hit_particles := load("res://level/ice_hit_particles.tscn") as PackedScene

func _ready() -> void:
	_goose_positions.append(goose_position_1)
	_goose_positions.append(goose_position_2)
	_goose_positions.append(goose_position_3)
	_goose_positions.append(goose_position_4)
	
	_duck_positions.append(duck_position_1)
	_duck_positions.append(duck_position_2)
	_duck_positions.append(duck_position_3)
	_duck_positions.append(duck_position_4)
	
	_lane_endings_goose_side.append(lane_end_goose_side_1)
	_lane_endings_goose_side.append(lane_end_goose_side_2)
	_lane_endings_goose_side.append(lane_end_goose_side_3)
	_lane_endings_goose_side.append(lane_end_goose_side_4)
	
	_lane_endings_duck_side.append(lane_end_duck_side_1)
	_lane_endings_duck_side.append(lane_end_duck_side_2)
	_lane_endings_duck_side.append(lane_end_duck_side_3)
	_lane_endings_duck_side.append(lane_end_duck_side_4)
	
	_on_round_start()
		
		
func _physics_process(_delta: float) -> void:
	var _goose_speed := 150
	if not _allow_input:
		pass
		
	elif Input.is_action_just_pressed("move_down"):
		_handle_goose_vertical_movement(true)
	
	elif Input.is_action_just_pressed("move_up"):
		_handle_goose_vertical_movement(false)
		
	elif _lane_tree_is_left[_goose_current_lane]:
		
		if Input.is_action_pressed("interact_right") and goose.position.x < GameInfo.grid_square_length * 14.5:
			goose.velocity.x = _goose_speed
			goose.move_and_slide()
			
		elif Input.is_action_just_released("interact_right"):
			_handle_goose_return_to_lane()
			
		elif Input.is_action_just_pressed("interact_left"):
			_on_whole_fruit_spawned()
		
	elif not _lane_tree_is_left[_goose_current_lane]:
		
		if Input.is_action_pressed("interact_left") and goose.position.x > GameInfo.grid_square_length * 1.5:
			goose.velocity.x = _goose_speed * -1
			goose.move_and_slide()
			
		elif Input.is_action_just_released("interact_left"):
			_handle_goose_return_to_lane()
			
		elif Input.is_action_just_pressed("interact_right"):
			_on_whole_fruit_spawned()
			
		
func _handle_goose_vertical_movement(is_down : bool) -> void:
	_allow_input = false
	
	if is_down:
		_goose_current_lane += 1
	else:
		_goose_current_lane -= 1
		
	if _goose_current_lane == 4:
		_goose_current_lane = 0
	elif _goose_current_lane == -1:
		_goose_current_lane = 3
		
	AudioController.play_sound_goose_move()
	var tween : Tween = create_tween()
	tween.tween_property(goose, "global_position",_goose_positions[_goose_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
	await tween.finished
	_allow_input = true
	
func _handle_goose_return_to_lane() -> void:
	_allow_input = false
	var tween : Tween = create_tween()
	tween.tween_property(goose, "global_position",_goose_positions[_goose_current_lane].global_position, 0.1).set_ease(Tween.EASE_OUT)
	await tween.finished
	_allow_input = true
	
		
func _spawn_duck() -> void:
	var new_duck_lane := randi_range(0, 3)
	var new_duck := duck.instantiate() as Duck
	var random_type_roll := randi_range(1, 100)
	_current_ducks_swimming.append(new_duck)
	
	var _percent_chance_basic_duck := 40
	var _percent_chance_fast_duck := 30
	var _percent_chance_hungry_duck := 20
	
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
	
	new_duck.connect("points_gained", _on_points_gained)
	new_duck.connect("eaten_fruit_spawned", _on_eaten_fruit_spawned)
	new_duck.connect("ice_spawned", _on_ice_spawned)
	new_duck.in_tree_left_lane = _lane_tree_is_left[new_duck_lane]
	new_duck.lane_number = new_duck_lane
	add_child.call_deferred(new_duck)
	new_duck.global_position = _duck_positions[new_duck_lane].global_position


func _restart_duck_spawn_timer() -> void:
	var _duck_spawn_min_sec := 2
	var _duck_spawn_max_sec := 4
	duck_spawn_timer.wait_time = randf_range(_duck_spawn_min_sec, _duck_spawn_max_sec)
	duck_spawn_timer.start()
	

func _on_life_lost(particle_position : Vector2) -> void:
	if not GameInfo.game_paused:
		GameInfo.lives -= 1
		game_overlay.update_lives_label()
		AudioController.play_sound_life_lost()
		
		var new_particles := lost_life_particles.instantiate() as CPUParticles2D
		add_child.call_deferred(new_particles)
		new_particles.global_position = particle_position
		new_particles.emitting = true
		await new_particles.finished
		new_particles.queue_free()
		
		if GameInfo.lives == 0:
			AudioController.play_sound_lose()
			_allow_input = false
			game_overlay.game_end(false)
			duck_spawn_timer.stop()
			GameInfo.game_paused = true


func _on_points_gained(points : int) -> void:
	_current_points += points
	game_overlay.update_points_label(_current_points)


func _on_eaten_fruit_spawned(fruit_position : Vector2, current_lane : int) -> void:
	var new_eaten_fruit := eaten_fruit.instantiate() as FruitEaten
	new_eaten_fruit.connect("life_lost", _on_life_lost)
	new_eaten_fruit.connect("points_gained", _on_points_gained)
	new_eaten_fruit.in_tree_left_lane = _lane_tree_is_left[current_lane]
	add_child.call_deferred(new_eaten_fruit)
	new_eaten_fruit.global_position = fruit_position
	
	
func _on_whole_fruit_spawned() -> void:
	_allow_input = false
	goose.play_animation("fruit_pick")
	await goose.animation_finished

	var new_fruit_whole := fruit_whole.instantiate() as FruitWhole
	new_fruit_whole.connect("life_lost", _on_life_lost)
	new_fruit_whole.in_tree_left_lane = _lane_tree_is_left[_goose_current_lane]
	add_child.call_deferred(new_fruit_whole)
	
	if _lane_tree_is_left[_goose_current_lane]:
		new_fruit_whole.global_position.x = _goose_positions[_goose_current_lane].global_position.x + GameInfo.grid_square_length
	else:
		new_fruit_whole.global_position.x = _goose_positions[_goose_current_lane].global_position.x - GameInfo.grid_square_length
	new_fruit_whole.global_position.y = _goose_positions[_goose_current_lane].global_position.y + (GameInfo.grid_square_length / 2.0)
	
	_allow_input = true

func _on_ice_spawned(ice_position : Vector2) -> void:
	var new_ice := ice.instantiate() as Ice
	new_ice.connect("ducks_frozen", _on_ducks_frozen)
	add_child.call_deferred(new_ice)
	new_ice.global_position = ice_position


func _on_ducks_frozen(particle_position : Vector2) -> void:
	for i in _current_ducks_swimming:
		i.toggle_frozen(true)
	duck_freeze.start()
	AudioController.toggle_music_volume(true)
	AudioController.play_sound_freeze()
	
	var new_particles := ice_hit_particles.instantiate() as CPUParticles2D
	add_child.call_deferred(new_particles)
	new_particles.global_position = particle_position
	new_particles.emitting = true
	await new_particles.finished
	new_particles.queue_free()
	

func _on_round_start() -> void:
	var current_map_type : MapTypes
		
	if _current_round % 8 == 1 or _current_round % 8 == 2:
		current_map_type = map_1
		
		if _background != null:
			_background.queue_free()
			
		_background = map_1_background.instantiate() as TileMapLayer
		
	elif _current_round % 8 == 3 or _current_round % 8 == 4:
		_background.queue_free()
		current_map_type = map_2
		_background = map_2_background.instantiate() as TileMapLayer
		
	elif _current_round % 8 == 5 or _current_round % 8 == 6:
		_background.queue_free()
		current_map_type = map_3
		_background = map_3_background.instantiate() as TileMapLayer
		
	elif _current_round % 8 == 7 or _current_round % 8 == 0:
		_background.queue_free()
		current_map_type = map_4
		_background = map_4_background.instantiate() as TileMapLayer
	
	var _duck_y_addition := 17
	
	var goose_x_left := 168
	var goose_x_right := 600
	var duck_x_left := 72
	var duck_x_right := 696
	var y_lanes : Array[int] = [144, 288, 432, 576]
	var safe_length : int = 4
	
	for i in 4:
		_lane_tree_is_left[i] = current_map_type.lane_is_left_tree[i]
		
		if _lane_tree_is_left[i]:
			_goose_positions[i].global_position = Vector2(goose_x_left, y_lanes[i])
			_duck_positions[i].global_position = Vector2(duck_x_right, y_lanes[i] + _duck_y_addition)
			_lane_endings_duck_side[i].global_position.x = _duck_positions[i].global_position.x + GameInfo.grid_square_length + safe_length
			_lane_endings_duck_side[i].global_position.y = _duck_positions[i].global_position.y
		
		else:
			_goose_positions[i].global_position = Vector2(goose_x_right, y_lanes[i])
			_duck_positions[i].global_position = Vector2(duck_x_left, y_lanes[i] + _duck_y_addition)
			_lane_endings_duck_side[i].global_position.x = _duck_positions[i].global_position.x - GameInfo.grid_square_length - safe_length
			_lane_endings_duck_side[i].global_position.y = _duck_positions[i].global_position.y
	
		_lane_endings_goose_side[i].global_position = _goose_positions[i].global_position
		
	for i in get_children():
		if i is FruitEaten or i is FruitWhole or i is Ice:
			i.queue_free()
	
	add_child.call_deferred(_background)
	game_overlay.update_round_label(_current_round)
	goose.global_position = _goose_positions[_goose_current_lane].global_position
	
	_round_current_ducks = 0
	_ducks_finished = 0
	_restart_duck_spawn_timer()


func _on_lane_end_goose_side_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		_on_life_lost(body.global_position)
		game_overlay.update_lives_label()
		_current_ducks_swimming.erase(body)
		body.queue_free()


func _on_lane_end_duck_side_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		_current_ducks_swimming.erase(body)
		body.queue_free()
		
		if _current_points >= 2000 and _ducks_finished == _round_max_ducks:
			_allow_input = false
			game_overlay.game_end(true)
			GameInfo.game_paused = true
			AudioController.play_sound_win()
			
		elif _ducks_finished == _round_max_ducks:
			_current_round += 1
			AudioController.play_sound_round_complete()
			
			if _current_round % 2 == 1:
				_allow_input = false
				GameInfo.game_paused = true
				var new_minigame := minigame.instantiate() as Minigame
				get_parent().add_child.call_deferred(new_minigame)
				
				var points_earned : int = await new_minigame.points_earned
				var life_earned : bool = await new_minigame.life_earned
				
				_allow_input = true
				GameInfo.game_paused = false
				_on_points_gained(points_earned)
				if life_earned:
					GameInfo.lives += 1
					game_overlay.update_lives_label()
				
			_on_round_start()


func _on_duck_spawn_timer_timeout() -> void:
	_spawn_duck()
	_round_current_ducks += 1
	if _round_current_ducks < _round_max_ducks:
		_restart_duck_spawn_timer()
	else:
		duck_spawn_timer.stop()


func _on_duck_freeze_timeout() -> void:
	for i in _current_ducks_swimming:
		i.toggle_frozen(false)
	AudioController.toggle_music_volume(false)
