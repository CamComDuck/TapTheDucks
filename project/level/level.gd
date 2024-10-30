extends Node2D

var _player_positions : Array[Marker2D] = []
var _duck_positions : Array[Marker2D] = []

@onready var player_position_1 := $PlayerPosition1
@onready var player_position_2 := $PlayerPosition2
@onready var player_position_3 := $PlayerPosition3
@onready var player_position_4 := $PlayerPosition4
@onready var player := $Player

@onready var duck_position_1 := $DuckPosition1
@onready var duck_position_2 := $DuckPosition2
@onready var duck_position_3 := $DuckPosition3
@onready var duck_position_4 := $DuckPosition4


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
	
	for i in 10:
		var new_duck_lane := randi_range(0, 3)
		var new_duck : Duck = load("res://duck/duck.tscn").instantiate()
		var new_duck_type := randi_range(0, 3)
		if new_duck_type == 0:
			new_duck.set_script(load("res://duck/duck_basic.gd"))
		elif new_duck_type == 1:
			new_duck.set_script(load("res://duck/duck_angry.gd"))
		elif new_duck_type == 2:
			new_duck.set_script(load("res://duck/duck_hungry.gd"))
		elif new_duck_type == 3:
			new_duck.set_script(load("res://duck/duck_fast.gd"))
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
