extends TabContainer

var _is_remapping := false
var _action_to_remap : String = "null"
var _is_volume_being_changed := false

@onready var input_button_move_up := $Keybinds/VBoxContainer/HBoxContainer/InputButtonMoveUp as Button
@onready var input_button_move_down := $Keybinds/VBoxContainer/HBoxContainer4/InputButtonMoveDown as Button
@onready var input_button_interact_left := $Keybinds/VBoxContainer/HBoxContainer5/InputButtonInteractLeft as Button
@onready var input_button_interact_right := $Keybinds/VBoxContainer/HBoxContainer6/InputButtonInteractRight as Button

@onready var basic_duck_texture := $Ducks/VBoxContainer/GridContainer/BasicDuckTexture as TextureRect
@onready var fast_duck_texture := $Ducks/VBoxContainer/GridContainer/FastDuckTexture as TextureRect
@onready var hungry_duck_texture := $Ducks/VBoxContainer/GridContainer/HungryDuckTexture as TextureRect
@onready var angry_duck_texture := $Ducks/VBoxContainer/GridContainer/AngryDuckTexture as TextureRect

@onready var basic_duck_points := $Ducks/VBoxContainer/GridContainer/BasicDuckPoints as Label
@onready var fast_duck_points := $Ducks/VBoxContainer/GridContainer/FastDuckPoints as Label
@onready var hungry_duck_points := $Ducks/VBoxContainer/GridContainer/HungryDuckPoints as Label
@onready var angry_duck_points := $Ducks/VBoxContainer/GridContainer/AngryDuckPoints as Label

@onready var duck_basic := load("res://duck/duck_types/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/duck_types/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/duck_types/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/duck_types/duck_angry.tres") as DuckTypes

@onready var master_percent := $Volume/VBoxContainer/HBoxMaster/MasterPercent as Label
@onready var music_percent := $Volume/VBoxContainer/HBoxMusic/MusicPercent as Label
@onready var sounds_percent := $Volume/VBoxContainer/HBoxSounds/SoundsPercent as Label

@onready var master_slider := $Volume/VBoxContainer/HBoxMaster/MasterSlider as HSlider
@onready var music_slider := $Volume/VBoxContainer/HBoxMusic/MusicSlider as HSlider
@onready var sounds_slider := $Volume/VBoxContainer/HBoxSounds/SoundsSlider as HSlider

func _ready() -> void:
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sounds_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	basic_duck_texture.modulate = duck_basic.color
	fast_duck_texture.modulate = duck_fast.color
	hungry_duck_texture.modulate = duck_hungry.color
	angry_duck_texture.modulate = duck_angry.color
	
	basic_duck_points.text = str(duck_basic.point_value)
	fast_duck_points.text = str(duck_fast.point_value)
	hungry_duck_points.text = str(duck_hungry.point_value)
	angry_duck_points.text = str(duck_angry.point_value)
	
	set_tab_icon(0, preload("res://goose/graphics/default_1.png"))
	#set_tab_icon(1, POINTS)
	set_tab_icon(2, preload("res://game_overlay/Points.png"))
	set_tab_icon(3, preload("res://duck/graphics/default_1.png"))
	
	_update_keybind_labels(true)
	
	
func _input(event : InputEvent) -> void:
	if _is_remapping:
		if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
				
			InputMap.action_erase_events(_action_to_remap)
			InputMap.action_add_event(_action_to_remap, event)
			
			_is_remapping = false
			_action_to_remap = "null"
			accept_event()
			_update_keybind_labels(false)


func _update_keybind_labels(is_reset : bool) -> void:
	if is_reset:
		InputMap.load_from_project_settings()
		
	for action in InputMap.get_actions():
		if action == "move_up":
			var events = InputMap.action_get_events(action)
			if not events.is_empty():
				input_button_move_up.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_button_move_up.text = ""
				
		elif action == "move_down":
			var events = InputMap.action_get_events(action)
			if not events.is_empty():
				input_button_move_down.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_button_move_down.text = ""
				
		elif action == "interact_left":
			var events = InputMap.action_get_events(action)
			if not events.is_empty():
				input_button_interact_left.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_button_interact_left.text = ""
				
		elif action == "interact_right":
			var events = InputMap.action_get_events(action)
			if not events.is_empty():
				input_button_interact_right.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_button_interact_right.text = ""
			

func _on_input_button_pressed(action : String, button : Button) -> void:
	if not _is_remapping:
		_is_remapping = true
		_action_to_remap = action
		button.text = "Press key to bind..."
		

func _on_input_button_move_up_pressed() -> void:
	_on_input_button_pressed("move_up", input_button_move_up)


func _on_input_button_move_down_pressed() -> void:
	_on_input_button_pressed("move_down", input_button_move_down)


func _on_input_button_interact_left_pressed() -> void:
	_on_input_button_pressed("interact_left", input_button_interact_left)


func _on_input_button_interact_right_pressed() -> void:
	_on_input_button_pressed("interact_right", input_button_interact_right)


func _on_reset_button_pressed() -> void:
	_update_keybind_labels(true)


func _on_master_slider_value_changed(value: float) -> void:
	master_percent.text = str(value*100) + "%"
	AudioServer.set_bus_volume_db(0, linear_to_db(master_slider.value))
	

func _on_music_slider_value_changed(value: float) -> void:
	music_percent.text = str(value*100) + "%"
	AudioServer.set_bus_volume_db(1, linear_to_db(music_slider.value))


func _on_sounds_slider_value_changed(value: float) -> void:
	sounds_percent.text = str(value*100) + "%"
	AudioServer.set_bus_volume_db(2, linear_to_db(sounds_slider.value))
	if _is_volume_being_changed:
		AudioController.play_sound_testing_volume()


func _on_master_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioController.play_sound_menu_click()


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioController.play_sound_menu_click()


func _on_sounds_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioController.play_sound_menu_click()


func _on_sounds_slider_mouse_entered() -> void:
	_is_volume_being_changed = true


func _on_sounds_slider_mouse_exited() -> void:
	_is_volume_being_changed = false
