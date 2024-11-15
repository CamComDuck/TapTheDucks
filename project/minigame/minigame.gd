extends Node2D

signal minigame_finished (points_earned : int, add_life : bool)

var _player_positions : Array[Marker2D] = []
var _hiding_spot_positions : Array[AnimatedSprite2D] = []

var _allow_input := false
var _player_current_spot_index := 2

var _correct_spot_index : int
var _selected_spot_index : int

var _is_extra_life_round : bool
var _life_found := false
var _points_eared : int

@onready var player := $Player as Player
@onready var finding_fruit := $FindingFruit as Sprite2D

@onready var hiding_spot_1 := $HidingSpot1 as AnimatedSprite2D
@onready var hiding_spot_2 := $HidingSpot2 as AnimatedSprite2D
@onready var hiding_spot_3 := $HidingSpot3 as AnimatedSprite2D
@onready var hiding_spot_4 := $HidingSpot4 as AnimatedSprite2D
@onready var hiding_spot_5 := $HidingSpot5 as AnimatedSprite2D

@onready var player_position_1 := $PlayerPosition1 as Marker2D
@onready var player_position_2 := $PlayerPosition2 as Marker2D
@onready var player_position_3 := $PlayerPosition3 as Marker2D
@onready var player_position_4 := $PlayerPosition4 as Marker2D
@onready var player_position_5 := $PlayerPosition5 as Marker2D

@onready var finding_fruit_normal := load("res://fruit/graphics/fruit_eaten.png") as Texture2D
@onready var finding_fruit_extra_life := load("res://fruit/graphics/fruit_whole.png") as Texture2D

func _ready() -> void:
	_player_positions.append(player_position_1)
	_player_positions.append(player_position_2)
	_player_positions.append(player_position_3)
	_player_positions.append(player_position_4)
	_player_positions.append(player_position_5)
	player.global_position = _player_positions[_player_current_spot_index].global_position
	
	_hiding_spot_positions.append(hiding_spot_1)
	_hiding_spot_positions.append(hiding_spot_2)
	_hiding_spot_positions.append(hiding_spot_3)
	_hiding_spot_positions.append(hiding_spot_4)
	_hiding_spot_positions.append(hiding_spot_5)
	
	_correct_spot_index = randi_range(0, _hiding_spot_positions.size() - 1)
	finding_fruit.global_position = _hiding_spot_positions[_correct_spot_index].global_position
	finding_fruit.hide()
	var extra_life_roll := randi_range(1, 10) 
	if extra_life_roll == 1:
		_is_extra_life_round = true
		finding_fruit.set_texture(finding_fruit_extra_life)
	else:
		_is_extra_life_round = false
		finding_fruit.set_texture(finding_fruit_normal)
		
	#print("Correct duck: " + str(_correct_spot_index + 1))
	await _show_wrong_shuffled_spots()
	_allow_input = true
	

func _physics_process(_delta: float) -> void:
	if not _allow_input:
		pass
		
	elif Input.is_action_just_pressed("interact_right"):
		_allow_input = false
		_player_current_spot_index += 1
		if _player_current_spot_index == 5:
			_player_current_spot_index = 0
		AudioController.play_sound_player_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_spot_index].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
	
	elif Input.is_action_just_pressed("interact_left"):
		_allow_input = false
		_player_current_spot_index -= 1
		if _player_current_spot_index == -1:
			_player_current_spot_index = 4
		AudioController.play_sound_player_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_spot_index].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
		
	elif Input.is_action_just_pressed("move_up"):
		_allow_input = false
		_selected_spot_index = _player_current_spot_index
		player.play_animation("minigame_pick")
		

func _show_wrong_shuffled_spots() -> void:
	var shuffled_spots : Array[AnimatedSprite2D] = _hiding_spot_positions.duplicate()
	shuffled_spots.remove_at(_correct_spot_index)
	shuffled_spots.shuffle()
	
	for i in shuffled_spots:
		await _on_reveal_spot(i, true, false)
		

func _on_reveal_spot(spot : AnimatedSprite2D, return_to_spot : bool, show_fruit : bool) -> void:
	var revealed_position := Vector2(spot.global_position.x, spot.global_position.y - (GameInfo.grid_square_length * 2))
	var tween_revealed : Tween = get_tree().create_tween()
	tween_revealed.tween_property(spot,"global_position",revealed_position, 1).set_ease(Tween.EASE_OUT)
	
	await tween_revealed.finished
	
	if show_fruit: # Replace with showing fruit when tween is halfway done
		finding_fruit.show()
	
	await create_tween().tween_interval(0.5).finished

	if return_to_spot:
		var return_position := Vector2(spot.global_position.x, spot.global_position.y + (GameInfo.grid_square_length * 2))
		var tween_return : Tween = get_tree().create_tween()
		tween_return.tween_property(spot,"global_position",return_position, 1).set_ease(Tween.EASE_OUT)
		await tween_return.finished


func _on_player_animation_finished() -> void:
	if _selected_spot_index == _correct_spot_index:
		await _on_reveal_spot(_hiding_spot_positions[_selected_spot_index], false, true)
		if _is_extra_life_round:
			_life_found = true
		
		_points_eared = 75
	else:
		await _on_reveal_spot(_hiding_spot_positions[_selected_spot_index], false, false)
		await _on_reveal_spot(_hiding_spot_positions[_correct_spot_index], false, true)
		_points_eared = 0
	
	await create_tween().tween_interval(1).finished
	minigame_finished.emit(_points_eared, _life_found)	
	queue_free()
