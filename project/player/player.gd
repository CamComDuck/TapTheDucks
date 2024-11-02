class_name Player
extends CharacterBody2D

signal animation_finished

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

func play_animation(animation : String) -> void:
	sprite_2d.play(animation)
	await sprite_2d.animation_finished
	animation_finished.emit()
	sprite_2d.play("default")
