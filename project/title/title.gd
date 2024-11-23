extends Node2D

@onready var help_container := $HelpContainer as TabContainer

func _ready() -> void:
	help_container.position.x = (GameInfo.grid_square_length * 8) - (help_container.size.x / 2)
	help_container.position.y = (GameInfo.grid_square_length * 8) - (help_container.size.y / 2)

func _on_start_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	get_tree().change_scene_to_file("res://level/level.tscn")


func _on_help_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	help_container.show()


func _on_help_menu_tab_changed(tab: int) -> void:
	AudioController.play_sound_menu_click()
	if tab == help_container.get_tab_count() - 1:
		help_container.hide()
		help_container.current_tab = 0
