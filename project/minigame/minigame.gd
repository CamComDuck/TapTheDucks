extends Node2D

signal minigame_finished (points_earned : int)

var _player_positions : Array[Marker2D] = []
var _hiding_spot_positions : Array[AnimatedSprite2D] = []

var _allow_input := true
var _player_current_spot := 0

var _correct_spot : int
var _selected_spot : int

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

func _ready() -> void:
	_player_positions.append(player_position_1)
	_player_positions.append(player_position_2)
	_player_positions.append(player_position_3)
	_player_positions.append(player_position_4)
	_player_positions.append(player_position_5)
	
	_hiding_spot_positions.append(hiding_spot_1)
	_hiding_spot_positions.append(hiding_spot_2)
	_hiding_spot_positions.append(hiding_spot_3)
	_hiding_spot_positions.append(hiding_spot_4)
	_hiding_spot_positions.append(hiding_spot_5)
	
	_correct_spot = randi_range(0, _hiding_spot_positions.size() - 1)
	finding_fruit.global_position = _hiding_spot_positions[_correct_spot].global_position
	finding_fruit.hide()
	print(_correct_spot)
	

func _physics_process(_delta: float) -> void:
	if not _allow_input:
		pass
		
	elif Input.is_action_just_pressed("interact_right"):
		_allow_input = false
		_player_current_spot += 1
		if _player_current_spot == 5:
			_player_current_spot = 0
		AudioController.play_sound_player_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_spot].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
	
	elif Input.is_action_just_pressed("interact_left"):
		_allow_input = false
		_player_current_spot -= 1
		if _player_current_spot == -1:
			_player_current_spot = 4
		AudioController.play_sound_player_move()
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(player, "global_position",_player_positions[_player_current_spot].global_position, 0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
		_allow_input = true
		
	elif Input.is_action_just_pressed("move_up"):
		_allow_input = false
		_selected_spot = _player_current_spot
		player.play_animation("minigame_pick")
		

func _on_button_testing_pressed() -> void:
	minigame_finished.emit(50)
	queue_free()


func _on_player_animation_finished() -> void:
	if _selected_spot == _correct_spot:
		finding_fruit.show()
		
	var chosen_position := Vector2(_hiding_spot_positions[_selected_spot].global_position.x, _hiding_spot_positions[_selected_spot].global_position.y - (GameInfo.grid_square_length * 2))
	var tween_chosen : Tween = get_tree().create_tween()
	tween_chosen.tween_property(_hiding_spot_positions[_selected_spot], "global_position",chosen_position, 0.25).set_ease(Tween.EASE_OUT)
	await tween_chosen.finished
	
	if _selected_spot == _correct_spot:
		pass
		
	else:
		finding_fruit.show()
		var correct_position := Vector2(_hiding_spot_positions[_correct_spot].global_position.x, _hiding_spot_positions[_correct_spot].global_position.y - (GameInfo.grid_square_length * 2))
		var tween_correct : Tween = get_tree().create_tween()
		tween_correct.tween_property(_hiding_spot_positions[_correct_spot], "global_position",correct_position, 0.25).set_ease(Tween.EASE_OUT)
		await tween_correct.finished
		
