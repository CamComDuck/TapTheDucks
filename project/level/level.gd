@icon("res://level/graphics/tree.png")
extends Node2D

var _goose_position_markers : Array[Marker2D] = []
var _duck_position_markers : Array[Marker2D] = []
var _lane_endings_goose_side_areas : Array[Area2D] = []
var _lane_endings_duck_side_areas : Array[Area2D] = []
var _on_screen_ducks : Array[Duck] = []
var _goose_lane_index : int
var _background : TileMapLayer = null

var _current_points := 0
var _round_num := 1
var _round_max_ducks := 4
var _round_current_ducks := 0
var _ducks_finished := 0
var _are_ducks_frozen := false
var _goose_swim_tween : Tween

var _is_tree_on_left_lane : Array[bool] = [true, true, true, true]

var _allow_input := true

@onready var game_overlay := $GameOverlay as GameOverlay
@onready var duck_spawn_timer := $DuckSpawnTimer as Timer
@onready var goose := $Goose as Goose

@onready var goose_positions := %GoosePositions as Node2D
@onready var duck_positions := %DuckPositions as Node2D
@onready var lane_end_goose_sides := %LaneEndGooseSides as Node2D
@onready var lane_end_duck_sides := %LaneEndDuckSides as Node2D

@onready var duck : = load("res://duck/duck.tscn") as PackedScene
@onready var duck_basic := load("res://duck/duck_types/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/duck_types/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/duck_types/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/duck_types/duck_angry.tres") as DuckTypes

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

@onready var firework_particles := load("res://level/firework_particles.tscn") as PackedScene

func _ready() -> void:
	
	for child in goose_positions.get_children():
		_goose_position_markers.append(child)
	
	for child in duck_positions.get_children():
		_duck_position_markers.append(child)
		
	for child in lane_end_goose_sides.get_children():
		_lane_endings_goose_side_areas.append(child)
	
	for child in lane_end_duck_sides.get_children():
		_lane_endings_duck_side_areas.append(child)
	
	_on_round_start()
		
		
func _physics_process(_delta: float) -> void:
	var _goose_speed := 200
	
	if _are_ducks_frozen:
		var frozen_time_left_percent := (duck_freeze.time_left / duck_freeze.wait_time) * 100
		game_overlay.update_freezer_progress_value(frozen_time_left_percent)
	
	if Input.is_action_just_pressed("pause"):
		if not GameInfo.player_paused and not GameInfo.system_paused:
			AudioController.play_sound_menu_click()
			_allow_input = false
			GameInfo.player_paused = true
			duck_spawn_timer.paused = true
			duck_freeze.paused = true
			game_overlay.toggle_pause_menu(true)
			if _goose_swim_tween != null:
				_goose_swim_tween.pause()
			for child in get_children():
				if child.has_method("on_game_paused"):
					child.on_game_paused(true)
		elif GameInfo.player_paused and not GameInfo.system_paused:
			AudioController.play_sound_menu_click()
			_allow_input = true
			GameInfo.player_paused = false
			duck_spawn_timer.paused = false
			duck_freeze.paused = false
			game_overlay.toggle_pause_menu(false)
			if _goose_swim_tween != null:
				if _goose_swim_tween.is_valid():
					_goose_swim_tween.play()
			elif goose.global_position.x != _goose_position_markers[0].global_position.x:
				_handle_goose_return_to_lane()
			for child in get_children():
				if child.has_method("on_game_paused"):
					child.on_game_paused(false)
	
	elif not _allow_input or GameInfo.player_paused or GameInfo.system_paused:
		pass
		
	elif Input.is_action_just_pressed("move_down"):
		_handle_goose_vertical_movement(true)
	
	elif Input.is_action_just_pressed("move_up"):
		_handle_goose_vertical_movement(false)
		
	elif _is_tree_on_left_lane[_goose_lane_index]:
		
		if Input.is_action_pressed("interact_right") and goose.position.x < GameInfo.grid_square_length * 14.5:
			if goose.current_animation != "swim":
				goose.play_animation("swim")
			goose.velocity.x = _goose_speed
			goose.move_and_slide()
			
		elif Input.is_action_just_released("interact_right"):
			_handle_goose_return_to_lane()
			
		elif Input.is_action_just_pressed("interact_left"):
			_on_whole_fruit_spawned()
		
	elif not _is_tree_on_left_lane[_goose_lane_index]:
		
		if Input.is_action_pressed("interact_left") and goose.position.x > GameInfo.grid_square_length * 1.5:
			if goose.current_animation != "swim":
				goose.play_animation("swim")
			goose.velocity.x = _goose_speed * -1
			goose.move_and_slide()
			
		elif Input.is_action_just_released("interact_left"):
			_handle_goose_return_to_lane()
			
		elif Input.is_action_just_pressed("interact_right"):
			_on_whole_fruit_spawned()
			
		
func _handle_goose_vertical_movement(is_down : bool) -> void:
	_allow_input = false
	
	if is_down:
		_goose_lane_index += 1
		goose.play_animation("move_down")
	else:
		_goose_lane_index -= 1
		goose.play_animation("move_up")
		
	if _goose_lane_index == 4:
		_goose_lane_index = 0
	elif _goose_lane_index == -1:
		_goose_lane_index = 3
		
	AudioController.play_sound_goose_move()
	
	var tween_fade_out : Tween = create_tween()
	tween_fade_out.tween_property(goose, "modulate", Color(1, 1, 1, 0), 0.08)
	
	await tween_fade_out.finished
	
	goose.global_position = _goose_position_markers[_goose_lane_index].global_position
	goose.flip_h(not _is_tree_on_left_lane[_goose_lane_index])
	
	var tween_fade_in : Tween = create_tween()
	tween_fade_in.tween_property(goose, "modulate", Color(1, 1, 1, 1), 0.08)
	
	await tween_fade_in.finished
	
	_allow_input = true
	
	
func _handle_goose_return_to_lane() -> void:
	_allow_input = false
	goose.flip_h(_is_tree_on_left_lane[_goose_lane_index])
	_goose_swim_tween = create_tween()
	var tween_time := absf(goose.global_position.x - _goose_position_markers[_goose_lane_index].global_position.x) * .002
	_goose_swim_tween.tween_property(goose, "global_position",_goose_position_markers[_goose_lane_index].global_position, tween_time)
	await _goose_swim_tween.finished
	goose.flip_h(not _is_tree_on_left_lane[_goose_lane_index])
	goose.play_animation("default")
	_allow_input = true
	
	
func _spawn_duck() -> void:
	_round_current_ducks += 1
	var new_duck_lane := randi_range(0, 3)
	var new_duck := duck.instantiate() as Duck
	var random_type_roll := randi_range(1, 100)
	_on_screen_ducks.append(new_duck)
	
	var round_multiplier := 0.25
	var max_duck_percents : Array[int] = [50, 30, 15]
	var _percent_chance_basic_duck := maxf(max_duck_percents[0] - (_round_num * round_multiplier), max_duck_percents[2]) 
	var _percent_chance_fast_duck := maxf(max_duck_percents[1] - (_round_num * round_multiplier), max_duck_percents[1])
	var _percent_chance_hungry_duck := minf(max_duck_percents[2] + (_round_num * round_multiplier), max_duck_percents[0])
	
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
	new_duck.in_tree_left_lane = _is_tree_on_left_lane[new_duck_lane]
	new_duck.lane_number = new_duck_lane
	add_child.call_deferred(new_duck)
	new_duck.global_position = _duck_position_markers[new_duck_lane].global_position


func _restart_duck_spawn_timer() -> void:
	var _duck_spawn_min_sec := maxf(( (-.0045*(_round_num * _round_num) + 2)), 0.4)
	var _duck_spawn_max_sec := maxf(( (-.09*(_round_num * _round_num) + 4)), 0.8)
	duck_spawn_timer.wait_time = randf_range(_duck_spawn_min_sec, _duck_spawn_max_sec)
	duck_spawn_timer.start()
	

func _fade_destroy_objects() -> void:
	GameInfo.system_paused = true
	for child in get_children():
		if child.has_method("on_game_paused"):
			child.on_game_paused(true)
	
	var tween_fade_out : Tween
	var faded_objects : Array[Node2D]
	for child in get_children():
		if child is FruitEaten or child is FruitWhole or child is Ice:
			tween_fade_out = create_tween().set_parallel()
			tween_fade_out.tween_property(child, "modulate", Color(1, 1, 1, 0), 0.3)
			faded_objects.append(child)
	
	if not faded_objects.is_empty():
		await tween_fade_out.finished
		for object in faded_objects:
			object.queue_free()
			
	GameInfo.system_paused = false
	for child in get_children():
		if child.has_method("on_game_paused"):
			child.on_game_paused(false)


func _on_life_lost(particle_position : Vector2) -> void:
	if not GameInfo.system_paused and not GameInfo.player_paused:
		GameInfo.lives -= 1
		game_overlay.update_lives_label()
		AudioController.play_sound_life_lost()
		
		var new_particles := firework_particles.instantiate() as Fireworks
		add_child.call_deferred(new_particles)
		new_particles.global_position = particle_position
		new_particles.color = Color("792426")
		new_particles.emitting = true
		
		
		if GameInfo.lives == 0: # Lose the Game
			AudioController.play_sound_lose()
			_allow_input = false
			game_overlay.game_stop(false)
			duck_spawn_timer.stop()
			GameInfo.system_paused = true
			for child in get_children():
				if child.has_method("on_game_paused"):
					child.on_game_paused(true)


func _on_points_gained(points : int) -> void:
	_current_points += points
	game_overlay.update_points_label(_current_points)


func _on_eaten_fruit_spawned(fruit_position : Vector2, current_lane : int) -> void:
	var new_eaten_fruit := eaten_fruit.instantiate() as FruitEaten
	new_eaten_fruit.connect("life_lost", _on_life_lost)
	new_eaten_fruit.connect("points_gained", _on_points_gained)
	new_eaten_fruit.in_tree_left_lane = _is_tree_on_left_lane[current_lane]
	add_child.call_deferred(new_eaten_fruit)
	new_eaten_fruit.global_position = fruit_position
	
	
func _on_whole_fruit_spawned() -> void:
	_allow_input = false
	goose.flip_h(_is_tree_on_left_lane[_goose_lane_index])
	goose.play_animation("fruit_pick")
	await goose.animation_finished
	goose.flip_h(not _is_tree_on_left_lane[_goose_lane_index])

	var new_fruit_whole := fruit_whole.instantiate() as FruitWhole
	new_fruit_whole.connect("life_lost", _on_life_lost)
	new_fruit_whole.in_tree_left_lane = _is_tree_on_left_lane[_goose_lane_index]
	add_child.call_deferred(new_fruit_whole)
	
	if _is_tree_on_left_lane[_goose_lane_index]:
		new_fruit_whole.global_position.x = _goose_position_markers[_goose_lane_index].global_position.x + GameInfo.grid_square_length
	else:
		new_fruit_whole.global_position.x = _goose_position_markers[_goose_lane_index].global_position.x - GameInfo.grid_square_length
	new_fruit_whole.global_position.y = _goose_position_markers[_goose_lane_index].global_position.y + (GameInfo.grid_square_length / 2.0)
	
	_allow_input = true

func _on_ice_spawned(ice_position : Vector2) -> void:
	var new_ice := ice.instantiate() as Ice
	new_ice.connect("ducks_frozen", _on_ducks_frozen)
	new_ice.connect("points_gained", _on_points_gained)
	add_child.call_deferred(new_ice)
	new_ice.global_position = ice_position


func _on_ducks_frozen(particle_position : Vector2) -> void:
	for i in _on_screen_ducks:
		i.toggle_frozen(true)
	duck_freeze.start()
	AudioController.toggle_music_volume(true)
	AudioController.play_sound_freeze()
	_are_ducks_frozen = true
	
	var new_particles := firework_particles.instantiate() as Fireworks
	add_child.call_deferred(new_particles)
	new_particles.global_position = particle_position
	new_particles.color = GameInfo.frozen_duck_color
	new_particles.emitting = true
	

func _on_round_start() -> void:
	await _fade_destroy_objects()
	
	var current_map_type : MapTypes
	if _background != null:
		_background.queue_free()
		
	if _round_num % 8 == 1 or _round_num % 8 == 2:
		current_map_type = map_1
		_background = map_1_background.instantiate() as TileMapLayer
		
	elif _round_num % 8 == 3 or _round_num % 8 == 4:
		current_map_type = map_2
		_background = map_2_background.instantiate() as TileMapLayer
		
	elif _round_num % 8 == 5 or _round_num % 8 == 6:
		current_map_type = map_3
		_background = map_3_background.instantiate() as TileMapLayer
		
	elif _round_num % 8 == 7 or _round_num % 8 == 0:
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
		_is_tree_on_left_lane[i] = current_map_type.lane_is_left_tree[i]
		
		if _is_tree_on_left_lane[i]:
			_goose_position_markers[i].global_position = Vector2(goose_x_left, y_lanes[i])
			_duck_position_markers[i].global_position = Vector2(duck_x_right, y_lanes[i] + _duck_y_addition)
			_lane_endings_duck_side_areas[i].global_position.x = _duck_position_markers[i].global_position.x + GameInfo.grid_square_length + safe_length
			_lane_endings_duck_side_areas[i].global_position.y = _duck_position_markers[i].global_position.y
		
		else:
			_goose_position_markers[i].global_position = Vector2(goose_x_right, y_lanes[i])
			_duck_position_markers[i].global_position = Vector2(duck_x_left, y_lanes[i] + _duck_y_addition)
			_lane_endings_duck_side_areas[i].global_position.x = _duck_position_markers[i].global_position.x - GameInfo.grid_square_length - safe_length
			_lane_endings_duck_side_areas[i].global_position.y = _duck_position_markers[i].global_position.y
	
		_lane_endings_goose_side_areas[i].global_position = _goose_position_markers[i].global_position
	
	add_child.call_deferred(_background)
	game_overlay.update_round_label(_round_num)
	goose.global_position = _goose_position_markers[_goose_lane_index].global_position
	goose.flip_h(not _is_tree_on_left_lane[_goose_lane_index])
	
	_round_current_ducks = 0
	_ducks_finished = 0
	_round_max_ducks = randi_range(_round_max_ducks, _round_num * 2)
	game_overlay.new_round_progress_bar(_round_max_ducks)
	
	var starting_duck_count : int = mini(ceili(randf_range(_round_max_ducks * 0.15, _round_max_ducks * 0.25)), 5)
	for i in starting_duck_count:
		_spawn_duck()
	_restart_duck_spawn_timer()


func _on_lane_end_goose_side_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		_on_life_lost(body.global_position)
		game_overlay.update_lives_label()
		_on_screen_ducks.erase(body)
		body.queue_free()
		game_overlay.update_round_progress_value(_ducks_finished)


func _on_lane_end_duck_side_body_entered(body: Node2D) -> void:
	if body is Duck:
		_ducks_finished += 1
		_on_screen_ducks.erase(body)
		body.queue_free()
		game_overlay.update_round_progress_value(_ducks_finished)
		
		if _current_points >= GameInfo.points_to_win and _ducks_finished == _round_max_ducks: # Win The Game
			_allow_input = false
			game_overlay.game_stop(true)
			GameInfo.system_paused = true
			AudioController.play_sound_win()
			for child in get_children():
				if child.has_method("on_game_paused"):
					child.on_game_paused(true)
			
		elif _ducks_finished == _round_max_ducks:
			_round_num += 1
			AudioController.play_sound_round_complete()
			
			if _round_num % 2 == 1:
				await _fade_destroy_objects()
				_allow_input = false
				GameInfo.system_paused = true
				var new_minigame := minigame.instantiate() as Minigame
				get_parent().add_child.call_deferred(new_minigame)
				
				var points_earned : int = await new_minigame.points_earned
				var life_earned : bool = await new_minigame.life_earned
				
				_allow_input = true
				GameInfo.system_paused = false
				_on_points_gained(points_earned)
				if life_earned:
					GameInfo.lives += 1
					game_overlay.update_lives_label()
				
			_on_round_start()


func _on_duck_spawn_timer_timeout() -> void:
	_spawn_duck()
	if _round_current_ducks < _round_max_ducks:
		_restart_duck_spawn_timer()
	else:
		duck_spawn_timer.stop()


func _on_duck_freeze_timeout() -> void:
	for i in _on_screen_ducks:
		i.toggle_frozen(false)
	AudioController.toggle_music_volume(false)
	_are_ducks_frozen = false
