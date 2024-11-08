class_name GameOverlay
extends Control

@onready var points_label := $PointsLabel as Label
@onready var game_end_container := $GameEndContainer as VBoxContainer
@onready var game_end_label := $GameEndContainer/GameEndLabel as Label
@onready var win_particles := $WinParticles as CPUParticles2D
@onready var lives_container := $LivesContainer as HBoxContainer
@onready var life := load("res://game_overlay/life.tscn") as PackedScene
@onready var round_label := $RoundLabel as Label

func update_lives_label() -> void:
	if lives_container.get_child_count() < Counters.lives and not Counters.game_end:
		var new_life := life.instantiate() as TextureRect
		lives_container.add_child.call_deferred(new_life)

	elif lives_container.get_child_count() > Counters.lives and lives_container.get_child_count() > 0:
		lives_container.get_child(0).queue_free()


func update_points_label(points : int) -> void:
	points_label.text = str(points)
	

func update_round_label(round_num : int) -> void:
	round_label.text = str(round_num)
	

func game_end(is_win : bool) -> void:
	if is_win:
		game_end_label.text = "You win!"
		win_particles.emitting = true
	else:
		game_end_label.text = "You lose!"
		
	game_end_container.position.x = 384 - (game_end_container.size.x / 2)
	game_end_container.position.y = 384 - (game_end_container.size.y / 2)
	game_end_container.show()


func _on_play_again_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	Counters.lives = 3
	Counters.game_end = false
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	Counters.lives = 3
	Counters.game_end = false
	get_tree().change_scene_to_packed(preload("res://title/title.tscn"))
