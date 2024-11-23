class_name GameOverlay
extends Control

@onready var points_label := $PointsLabel as Label
@onready var game_stop_container := $GameStopContainer as VBoxContainer
@onready var game_stop_label := $GameStopContainer/GameStopLabel as Label
@onready var win_particles := $WinParticles as CPUParticles2D
@onready var lives_container := $LivesContainer as HBoxContainer
@onready var life := load("res://game_overlay/life.tscn") as PackedScene
@onready var round_label := $RoundLabel as Label
@onready var round_progress_slider := $RoundProgressSlider as HSlider
@onready var freeze_timer_container := $FreezeTimerContainer as VBoxContainer
@onready var texture_progress_bar := $FreezeTimerContainer/TextureProgressBar as TextureProgressBar
@onready var pause_label := $GameStopContainer/PauseLabel as Label
@onready var play_again_button := $GameStopContainer/PlayAgainButton as Button
@onready var menu_button := $GameStopContainer/MenuButton as Button

func update_freezer_progress_value(value : float) -> void:
	if not freeze_timer_container.visible:
		freeze_timer_container.show()
	texture_progress_bar.value = value
	if value < 0.5:
		freeze_timer_container.hide()


func update_round_progress_value(value : int) -> void:
	round_progress_slider.value = value
	

func new_round_progress_bar(max_ducks : int) -> void:
	round_progress_slider.tick_count = max_ducks + 1
	round_progress_slider.max_value = max_ducks
	round_progress_slider.value = 0


func update_lives_label() -> void:
	if lives_container.get_child_count() < GameInfo.lives and not GameInfo.game_paused:
		var new_life := life.instantiate() as TextureRect
		lives_container.add_child.call_deferred(new_life)

	elif lives_container.get_child_count() > GameInfo.lives and lives_container.get_child_count() > 0:
		lives_container.get_child(0).queue_free()


func update_points_label(points : int) -> void:
	points_label.text = str(points)
	

func update_round_label(round_num : int) -> void:
	round_label.text = str(round_num)
	

func game_stop(stop_type : String) -> void:
	game_stop_container.position.x = (GameInfo.grid_square_length * 8) - (game_stop_container.size.x / 2)
	game_stop_container.position.y = (GameInfo.grid_square_length * 8) - (game_stop_container.size.y / 2)
	
	if stop_type == "WIN":
		game_stop_label.text = "You win!"
		win_particles.emitting = true
		pause_label.hide()
		play_again_button.show()
		menu_button.show()
		game_stop_container.show()
	elif stop_type == "LOSE":
		game_stop_label.text = "You lose!"
		pause_label.hide()
		play_again_button.show()
		menu_button.show()
		game_stop_container.show()
	elif stop_type == "PAUSE":
		game_stop_label.text = "Paused"
		var pause_event = InputMap.action_get_events("pause")
		var pause_keybind = pause_event[0].as_text().trim_suffix(" (Physical)")
		pause_label.text = "Press " + pause_keybind + " to unpause"
		pause_label.show()
		play_again_button.hide()
		menu_button.hide()
		game_stop_container.show()
	elif stop_type == "UNPAUSE":
		game_stop_container.hide()


func _on_play_again_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	GameInfo.lives = 3
	GameInfo.system_paused = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	GameInfo.lives = 3
	GameInfo.system_paused = false
	get_tree().change_scene_to_packed(preload("res://title/title.tscn"))
