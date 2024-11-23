extends Node2D

@onready var settings_container := %SettingsContainer as TabContainer
@onready var customization_container: TabContainer = $CustomizationContainer

func _ready() -> void:
	settings_container.position.x = (GameInfo.grid_square_length * 8) - (settings_container.size.x / 2)
	settings_container.position.y = (GameInfo.grid_square_length * 8) - (settings_container.size.y / 2)
	
	customization_container.position.x = (GameInfo.grid_square_length * 8) - (customization_container.size.x / 2)
	customization_container.position.y = (GameInfo.grid_square_length * 8) - (settings_container.size.y / 2)


func _on_start_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	get_tree().change_scene_to_file("res://level/level.tscn")


func _on_help_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	settings_container.show()


func _on_help_menu_tab_changed(tab: int) -> void:
	AudioController.play_sound_menu_click()
	if tab == settings_container.get_tab_count() - 1:
		settings_container.hide()
		settings_container.current_tab = 0


func _on_customization_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	customization_container.show()

func _on_customization_container_tab_changed(tab: int) -> void:
	AudioController.play_sound_menu_click()
	if tab == customization_container.get_tab_count() - 1:
		customization_container.hide()
		customization_container.current_tab = 0
