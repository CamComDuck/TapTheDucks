extends Node2D

@onready var help_container := $HelpContainer as TabContainer

@onready var basic_duck_texture := $HelpContainer/Ducks/VBoxContainer/GridContainer/BasicDuckTexture as TextureRect
@onready var fast_duck_texture := $HelpContainer/Ducks/VBoxContainer/GridContainer/FastDuckTexture as TextureRect
@onready var hungry_duck_texture := $HelpContainer/Ducks/VBoxContainer/GridContainer/HungryDuckTexture as TextureRect
@onready var angry_duck_texture := $HelpContainer/Ducks/VBoxContainer/GridContainer/AngryDuckTexture as TextureRect

@onready var basic_duck_points := $HelpContainer/Ducks/VBoxContainer/GridContainer/BasicDuckPoints as Label
@onready var fast_duck_points := $HelpContainer/Ducks/VBoxContainer/GridContainer/FastDuckPoints as Label
@onready var hungry_duck_points := $HelpContainer/Ducks/VBoxContainer/GridContainer/HungryDuckPoints as Label
@onready var angry_duck_points := $HelpContainer/Ducks/VBoxContainer/GridContainer/AngryDuckPoints as Label

@onready var duck_basic := load("res://duck/duck_types/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/duck_types/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/duck_types/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/duck_types/duck_angry.tres") as DuckTypes

func _ready() -> void:
	basic_duck_texture.modulate = duck_basic.color
	fast_duck_texture.modulate = duck_fast.color
	hungry_duck_texture.modulate = duck_hungry.color
	angry_duck_texture.modulate = duck_angry.color
	
	basic_duck_points.text = str(duck_basic.point_value)
	fast_duck_points.text = str(duck_fast.point_value)
	hungry_duck_points.text = str(duck_hungry.point_value)
	angry_duck_points.text = str(duck_angry.point_value)
	

func _on_start_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	get_tree().change_scene_to_file("res://level/level.tscn")


func _on_help_button_toggled(toggled_on: bool) -> void:
	AudioController.play_sound_menu_click()
	if toggled_on:
		help_container.show()
	else:
		help_container.hide()


func _on_help_menu_tab_changed(_tab: int) -> void:
	AudioController.play_sound_menu_click()
