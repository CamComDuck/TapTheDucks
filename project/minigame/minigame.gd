@icon("res://game_overlay/icon_point.png")
class_name Minigame
extends Node2D

signal points_earned (points_earned : int)
signal life_earned (add_life : bool)

var _goose_positions : Array[Marker2D] = []
var _hiding_spot_positions : Array[AnimatedSprite2D] = []

var _allow_input := false
var _goose_current_spot_index := 2

var _correct_spot : AnimatedSprite2D
var _selected_spot : AnimatedSprite2D

var _is_extra_life_round : bool
var _life_found := false
var _points_eared : int

@onready var goose := $Goose as Goose

@onready var instruction_label := $InstructionLabel as Label

@onready var hiding_spot_1 := $HidingSpot1 as AnimatedSprite2D
@onready var hiding_spot_2 := $HidingSpot2 as AnimatedSprite2D
@onready var hiding_spot_3 := $HidingSpot3 as AnimatedSprite2D
@onready var hiding_spot_4 := $HidingSpot4 as AnimatedSprite2D
@onready var hiding_spot_5 := $HidingSpot5 as AnimatedSprite2D
@onready var hiding_spot_6 := $HidingSpot6 as AnimatedSprite2D

@onready var goose_position_1 := $GoosePosition1 as Marker2D
@onready var goose_position_2 := $GoosePosition2 as Marker2D
@onready var goose_position_3 := $GoosePosition3 as Marker2D
@onready var goose_position_4 := $GoosePosition4 as Marker2D
@onready var goose_position_5 := $GoosePosition5 as Marker2D
@onready var goose_position_6 := $GoosePosition6 as Marker2D

@onready var finding_fruit := $FindingFruit as Sprite2D
@onready var finding_fruit_normal := load("res://fruit/graphics/fruit_eaten.png") as Texture2D
@onready var finding_fruit_extra_life := load("res://fruit/graphics/fruit_whole.png") as Texture2D

func _ready() -> void:
	goose.hide()
	modulate = Color(1, 1, 1, 0)
	var tween_fade_in : Tween = create_tween()
	tween_fade_in.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	await tween_fade_in.finished
	AudioController.pause_sound_background_music()
	AudioController.pause_sound_minigame_music()
	
	_goose_positions.append(goose_position_1)
	_goose_positions.append(goose_position_2)
	_goose_positions.append(goose_position_3)
	_goose_positions.append(goose_position_4)
	_goose_positions.append(goose_position_5)
	_goose_positions.append(goose_position_6)
	goose.global_position = _goose_positions[_goose_current_spot_index].global_position
	
	_hiding_spot_positions.append(hiding_spot_1)
	_hiding_spot_positions.append(hiding_spot_2)
	_hiding_spot_positions.append(hiding_spot_3)
	_hiding_spot_positions.append(hiding_spot_4)
	_hiding_spot_positions.append(hiding_spot_5)
	_hiding_spot_positions.append(hiding_spot_6)
	
	_correct_spot = _hiding_spot_positions.pick_random()
	#print("Correct duck: " + str(_correct_spot))
	
	var extra_life_roll := randi_range(1, 10) 
	if extra_life_roll == 1:
		_is_extra_life_round = true
		finding_fruit.set_texture(finding_fruit_extra_life)
	else:
		_is_extra_life_round = false
		finding_fruit.set_texture(finding_fruit_normal)
	
	instruction_label.text = tr("MINIGAME_LINE_1")
	instruction_label.global_position = Vector2(GameInfo.grid_square_length * 8.0 - (instruction_label.size.x / 2.0), GameInfo.grid_square_length * 2.0)
	await create_tween().tween_interval(0.7).finished
	instruction_label.show()
	await create_tween().tween_interval(0.15).finished
	instruction_label.hide()
	await create_tween().tween_interval(0.15).finished
	instruction_label.show()
	await create_tween().tween_interval(2).finished
	instruction_label.hide()
	
	await _show_wrong_shuffled_spots()
	
	instruction_label.text = tr("MINIGAME_LINE_2")
	instruction_label.global_position = Vector2(GameInfo.grid_square_length * 8.0 - (instruction_label.size.x / 2.0), instruction_label.global_position.y)
	instruction_label.show()
	await create_tween().tween_interval(1.5).finished
	instruction_label.hide()
	
	var x_positions : Array[int] = [144, 240, 336, 432, 528, 624]
	for i in 15:
		var left_index_1 := randi_range(1, x_positions.size() - 3)
		var left_index_2 := randi_range(left_index_1 + 2, x_positions.size()-1)
		var right_index_1 := left_index_1 - 1
		var right_index_2 := left_index_2 - 1

		var move_left_1 : AnimatedSprite2D
		var move_left_2 : AnimatedSprite2D
		var move_right_1 : AnimatedSprite2D
		var move_right_2 : AnimatedSprite2D
		
		for spot in _hiding_spot_positions:
			if spot.global_position.x == x_positions[left_index_1]:
				move_left_1 = spot
			elif spot.global_position.x == x_positions[right_index_1]:
				move_right_1 = spot
			elif spot.global_position.x == x_positions[left_index_2]:
				move_left_2 = spot
			elif spot.global_position.x == x_positions[right_index_2]:
				move_right_2 = spot
				
		
		await _mix_spots(move_left_1, move_left_2, move_right_1, move_right_2)
	
	finding_fruit.global_position = _correct_spot.global_position
	goose.show()
	instruction_label.text = tr("MINIGAME_LINE_3")
	instruction_label.global_position = Vector2(GameInfo.grid_square_length * 8.0 - (instruction_label.size.x / 2.0), instruction_label.global_position.y)
	instruction_label.show()
	_allow_input = true
	

func _physics_process(_delta: float) -> void:
	if not _allow_input:
		pass
		
	elif Input.is_action_just_pressed("interact_right"):
		_allow_input = false
		_goose_current_spot_index += 1
		if _goose_current_spot_index == 6:
			_goose_current_spot_index = 0
		AudioController.play_sound_goose_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(goose, "global_position",_goose_positions[_goose_current_spot_index].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
	
	elif Input.is_action_just_pressed("interact_left"):
		_allow_input = false
		_goose_current_spot_index -= 1
		if _goose_current_spot_index == -1:
			_goose_current_spot_index = 5
		AudioController.play_sound_goose_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(goose, "global_position",_goose_positions[_goose_current_spot_index].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
		
	elif Input.is_action_just_pressed("move_up"):
		_allow_input = false
		for i in _hiding_spot_positions:
			if i.global_position.x == goose.global_position.x:
				_selected_spot = i
		goose.play_animation("minigame_pick")
		

func _show_wrong_shuffled_spots() -> void:
	var shuffled_spots : Array[AnimatedSprite2D] = _hiding_spot_positions.duplicate()
	shuffled_spots.erase(_correct_spot)
	shuffled_spots.shuffle()
	
	for i in shuffled_spots:
		await _on_reveal_spot(i, true, false)
		

func _mix_spots(move_left_1 : AnimatedSprite2D, move_left_2 : AnimatedSprite2D, move_right_1 : AnimatedSprite2D, move_right_2 : AnimatedSprite2D) -> void:
	await create_tween().tween_interval(0.1).finished
	var transition := Tween.TRANS_SPRING
	
	# Left-Moving Ducks Move Up
	var tween_up := create_tween().set_parallel().set_trans(transition)
	var up_position_1 := Vector2(move_left_1.global_position.x - (GameInfo.grid_square_length), move_left_1.global_position.y -  (GameInfo.grid_square_length * 2))
	tween_up.tween_property(move_left_1,"global_position",up_position_1, .15)
	var up_position_2 := Vector2(move_left_2.global_position.x - (GameInfo.grid_square_length), move_left_2.global_position.y -  (GameInfo.grid_square_length * 2))
	tween_up.tween_property(move_left_2,"global_position",up_position_2, .15)
	await tween_up.finished
	move_left_1.global_position = up_position_1
	move_left_2.global_position = up_position_2
	
	# Right-Moving Ducks Move Right
	var tween_right := create_tween().set_parallel().set_trans(transition)
	var right_position_1 := Vector2(move_right_1.global_position.x + (GameInfo.grid_square_length * 2), move_right_1.global_position.y)
	tween_right.tween_property(move_right_1,"global_position",right_position_1, .1)
	var right_position_2 := Vector2(move_right_2.global_position.x + (GameInfo.grid_square_length * 2), move_right_2.global_position.y)
	tween_right.tween_property(move_right_2,"global_position",right_position_2, .1)
	await tween_right.finished
	move_right_1.global_position = right_position_1
	move_right_2.global_position = right_position_2
	
	# Left-Moving Ducks Move Down
	var tween_down := create_tween().set_parallel().set_trans(transition)
	var down_position_1 := Vector2(move_left_1.global_position.x -  (GameInfo.grid_square_length), move_left_1.global_position.y +  (GameInfo.grid_square_length * 2))
	tween_down.tween_property(move_left_1,"global_position",down_position_1, .15)
	var down_position_2 := Vector2(move_left_2.global_position.x -  (GameInfo.grid_square_length), move_left_2.global_position.y +  (GameInfo.grid_square_length * 2))
	tween_down.tween_property(move_left_2,"global_position",down_position_2, .15)
	await tween_down.finished
	move_left_1.global_position = down_position_1
	move_left_2.global_position = down_position_2
	

func _on_reveal_spot(spot : AnimatedSprite2D, return_to_spot : bool, show_fruit : bool) -> void:
	var revealed_position := Vector2(spot.global_position.x, spot.global_position.y - (GameInfo.grid_square_length * 2))
	var tween_revealed : Tween = get_tree().create_tween().set_parallel()
	tween_revealed.tween_property(spot,"global_position",revealed_position, 0.25).set_ease(Tween.EASE_OUT)
	if show_fruit: 
		tween_revealed.tween_callback(Callable(finding_fruit, "show")).set_delay(0.05)
	
	await tween_revealed.finished
	await create_tween().tween_interval(0.2).finished

	if return_to_spot:
		var return_position := Vector2(spot.global_position.x, spot.global_position.y + (GameInfo.grid_square_length * 2))
		var tween_return : Tween = get_tree().create_tween()
		tween_return.tween_property(spot,"global_position",return_position, 0.25).set_ease(Tween.EASE_OUT)
		await tween_return.finished


func _on_goose_animation_finished() -> void:
	instruction_label.hide()
	if goose.global_position.x == _correct_spot.global_position.x:
		await _on_reveal_spot(_selected_spot, false, true)
		AudioController.pause_sound_minigame_music()
		AudioController.play_sound_minigame_correct()
		if _is_extra_life_round:
			_life_found = true
		
		_points_eared = 3000
	else:
		await _on_reveal_spot(_selected_spot, false, false)
		AudioController.pause_sound_minigame_music()
		AudioController.play_sound_minigame_wrong()
		await _on_reveal_spot(_correct_spot, false, true)
		_points_eared = 0
	
	await create_tween().tween_interval(2.5).finished
	points_earned.emit(_points_eared)
	life_earned.emit(_life_found)
	
	
	AudioController.pause_sound_background_music()
	var tween_fade_out : Tween = create_tween()
	tween_fade_out.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween_fade_out.finished
	queue_free()
