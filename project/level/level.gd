extends Node2D

var _lane_positions := []

@onready var lane_position_1: Marker2D = $LanePosition1
@onready var lane_position_2: Marker2D = $LanePosition2
@onready var lane_position_3: Marker2D = $LanePosition3
@onready var lane_position_4: Marker2D = $LanePosition4
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	#var new_duck = load("res://duck/duck.tscn").instantiate()
	#new_duck.set_script(load("res://duck/duck_basic.gd"))
	#get_parent().add_child.call_deferred(new_duck)
	#new_duck.global_position = Vector2i(200, 200)
	_lane_positions.append(lane_position_1)
	_lane_positions.append(lane_position_2)
	_lane_positions.append(lane_position_3)
	_lane_positions.append(lane_position_4)
	player.global_position = _lane_positions[0].global_position


func _on_player_lane_changed(new_lane: int) -> void:
	player.global_position = _lane_positions[new_lane - 1].global_position
