extends Node2D

@onready var help_container: PanelContainer = $HelpContainer

@onready var basic_duck_texture: TextureRect = $HelpContainer/VBoxContainer/BasicDuck/BasicDuckTexture
@onready var fast_duck_texture: TextureRect = $HelpContainer/VBoxContainer/FastDuck/FastDuckTexture
@onready var hungry_duck_texture: TextureRect = $HelpContainer/VBoxContainer/HungryDuck/HungryDuckTexture
@onready var angry_duck_texture: TextureRect = $HelpContainer/VBoxContainer/AngryDuck/AngryDuckTexture

@onready var duck_basic := load("res://duck/resources/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/resources/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/resources/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/resources/duck_angry.tres") as DuckTypes

func _ready() -> void:
	basic_duck_texture.modulate = duck_basic.color
	fast_duck_texture.modulate = duck_fast.color
	hungry_duck_texture.modulate = duck_hungry.color
	angry_duck_texture.modulate = duck_angry.color


func _on_start_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	get_tree().change_scene_to_file("res://level/level.tscn")


func _on_help_button_toggled(toggled_on: bool) -> void:
	AudioController.play_sound_menu_click()
	if toggled_on:
		help_container.show()
	else:
		help_container.hide()
