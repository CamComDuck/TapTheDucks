extends Node2D

var tab_hovered_stylebox : StyleBoxFlat
var tab_hovered_font_color : Color
var tab_unselected_stylebox : StyleBoxFlat
var tab_unselected_font_color : Color

@onready var settings_container := %SettingsContainer as TabContainer
@onready var customization_container: TabContainer = $CustomizationContainer

func _ready() -> void:
	settings_container.position.x = (GameInfo.grid_square_length * 8) - (settings_container.size.x / 2)
	settings_container.position.y = (GameInfo.grid_square_length * 8) - (settings_container.size.y / 2)
	
	customization_container.position.x = (GameInfo.grid_square_length * 8) - (customization_container.size.x / 2)
	customization_container.position.y = (GameInfo.grid_square_length * 8) - (customization_container.size.y / 2)


	tab_hovered_stylebox = settings_container.get_theme_stylebox("tab_hovered")
	tab_hovered_font_color = settings_container.get_theme_color("font_hovered_color")
	tab_unselected_stylebox = settings_container.get_theme_stylebox("tab_unselected")
	tab_unselected_font_color = settings_container.get_theme_color("font_unselected_color")

func _on_start_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	get_tree().change_scene_to_file("res://level/level.tscn")


func _on_help_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	settings_container.add_theme_stylebox_override("tab_hovered", tab_hovered_stylebox)
	settings_container.add_theme_color_override("font_hovered_color", tab_hovered_font_color)
	settings_container.show()


func _on_help_menu_tab_changed(tab: int) -> void:
	AudioController.play_sound_menu_click()
	if tab == settings_container.get_tab_count() - 1:
		settings_container.hide()
		settings_container.current_tab = 0
		
		settings_container.add_theme_stylebox_override("tab_hovered", tab_unselected_stylebox)
		settings_container.add_theme_color_override("font_hovered_color", tab_unselected_font_color)


func _on_customization_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	customization_container.add_theme_stylebox_override("tab_hovered", tab_hovered_stylebox)
	customization_container.add_theme_color_override("font_hovered_color", tab_hovered_font_color)

	customization_container.show()
	

func _on_customization_container_tab_changed(tab: int) -> void:
	AudioController.play_sound_menu_click()
	if tab == customization_container.get_tab_count() - 1:
		customization_container.hide()
		customization_container.current_tab = 0
		
		customization_container.add_theme_stylebox_override("tab_hovered", tab_unselected_stylebox)
		customization_container.add_theme_color_override("font_hovered_color", tab_unselected_font_color)
