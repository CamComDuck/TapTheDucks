@icon("res://game_overlay/icon_goose.png")
class_name Goose
extends CharacterBody2D

signal animation_finished

var current_animation : String = "default"

@onready var sprite_2d := $Sprite2D as AnimatedSprite2D

func _ready() -> void:
	sprite_2d.modulate = GameInfo.goose_color

func play_animation(animation : String) -> void:
	current_animation = animation
	sprite_2d.play(animation)
	await sprite_2d.animation_finished
	animation_finished.emit()
	sprite_2d.play("default")
	current_animation = "default"


func flip_h(face_left : bool) -> void:
	sprite_2d.flip_h = face_left


func on_game_paused(is_paused : bool) -> void:
	if is_paused:
		sprite_2d.pause()
	else:
		sprite_2d.play()
