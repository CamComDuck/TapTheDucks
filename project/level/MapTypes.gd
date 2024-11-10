class_name MapTypes
extends Resource

@export var map_number : int
@export var player_on_left : bool = true

@export_category("Lane Directions")
@export var lane_1_is_left_tree : bool = true
@export var lane_2_is_left_tree : bool = true
@export var lane_3_is_left_tree : bool = true
@export var lane_4_is_left_tree : bool = true

@export_category("Player Positions")
@export var player_position_1 : Vector2
@export var player_position_2 : Vector2
@export var player_position_3 : Vector2
@export var player_position_4 : Vector2

@export_category("Duck Positions")
@export var duck_position_1 : Vector2
@export var duck_position_2 : Vector2
@export var duck_position_3 : Vector2
@export var duck_position_4 : Vector2

@export_category("Lane End Positions")
@export var lane_end_player_side_position : Vector2
@export var lane_end_duck_side_position : Vector2
