extends CharacterBody2D

signal lane_changed (new_lane : int)

var _lane := 1

@onready var player_move: AudioStreamPlayer = $PlayerMove

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		_lane -= 1
		if _lane == 0:
			_lane = 4
		lane_changed.emit(_lane)
		player_move.play()
		
	elif Input.is_action_just_pressed("move_down"):
		_lane += 1
		if _lane == 5:
			_lane = 1
		lane_changed.emit(_lane)
		player_move.play()
