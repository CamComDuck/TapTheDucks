@icon("res://goose/graphics/default_1.png")
class_name Goose
extends CharacterBody2D

signal animation_finished

@onready var sprite_2d := $Sprite2D as AnimatedSprite2D

func play_animation(animation : String) -> void:
	sprite_2d.play(animation)
	await sprite_2d.animation_finished
	animation_finished.emit()
	sprite_2d.play("default")
