extends TabContainer

var _is_remapping := false
var _action_to_remap : String = "null"
var _is_volume_being_changed := false
var _volume_sliders : Array[HSlider]

@onready var input_button_move_up := $Keybinds/VBoxContainer/HBoxContainer/InputButtonMoveUp as Button
@onready var input_button_move_down := $Keybinds/VBoxContainer/HBoxContainer4/InputButtonMoveDown as Button
@onready var input_button_interact_left := $Keybinds/VBoxContainer/HBoxContainer5/InputButtonInteractLeft as Button
@onready var input_button_interact_right := $Keybinds/VBoxContainer/HBoxContainer6/InputButtonInteractRight as Button
@onready var input_button_pause := $Keybinds/VBoxContainer/HBoxContainer7/InputButtonPause as Button

@onready var volume_vbox := $Volume/VBoxContainer as VBoxContainer
@onready var master_percent := %MasterPercent as Label
@onready var music_percent := %MusicPercent as Label
@onready var sounds_percent := %SoundsPercent as Label

func _ready() -> void:
	var volume_vbox_children = volume_vbox.get_children()
	for vbox_node in volume_vbox_children:
		if vbox_node is HBoxContainer:
			var volume_hbox_children = vbox_node.get_children()
			for hbox_node in volume_hbox_children:
				if hbox_node is HSlider:
					_volume_sliders.append(hbox_node)
					hbox_node.value = db_to_linear(AudioServer.get_bus_volume_db(_volume_sliders.size() - 1))
	
	#set_tab_icon(0, preload("res://game_overlay/icon_goose.png"))
	#set_tab_icon(1, POINTS)
	
	set_tab_title(0, tr("KEYBINDS_HEADER"))
	set_tab_title(1, tr("VOLUME_HEADER"))
	set_tab_title(2, tr("LANGUAGE_HEADER"))
	set_tab_title(3, tr("EXIT_MENU_HEADER"))
	
	
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
				
		elif action == "pause":
			var events = InputMap.action_get_events(action)
			if not events.is_empty():
				input_button_pause.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_button_interact_right.text = ""
			

func _on_input_button_pressed(action : String, button : Button) -> void:
	if not _is_remapping:
		_is_remapping = true
		_action_to_remap = action
		button.text = tr("KEYBINDS_WAIT")
		

func _on_input_button_move_up_pressed() -> void:
	_on_input_button_pressed("move_up", input_button_move_up)


func _on_input_button_move_down_pressed() -> void:
	_on_input_button_pressed("move_down", input_button_move_down)


func _on_input_button_interact_left_pressed() -> void:
	_on_input_button_pressed("interact_left", input_button_interact_left)


func _on_input_button_interact_right_pressed() -> void:
	_on_input_button_pressed("interact_right", input_button_interact_right)


func _on_input_button_pause_pressed() -> void:
	_on_input_button_pressed("pause", input_button_pause)


func _on_reset_button_pressed() -> void:
	_update_keybind_labels(true)


func _on_master_slider_value_changed(value: float) -> void:
	master_percent.text = str(value*100) + "%"
	AudioServer.set_bus_volume_db(0, linear_to_db(_volume_sliders[0].value))
	

func _on_music_slider_value_changed(value: float) -> void:
	music_percent.text = str(value*100) + "%"
	AudioServer.set_bus_volume_db(1, linear_to_db(_volume_sliders[1].value))


func _on_sounds_slider_value_changed(value: float) -> void:
	sounds_percent.text = str(value*100) + "%"
	AudioServer.set_bus_volume_db(2, linear_to_db(_volume_sliders[2].value))
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


func _on_english_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	TranslationServer.set_locale("en")
	

func _on_french_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	TranslationServer.set_locale("fr")


func _on_korean_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	TranslationServer.set_locale("ko")


func _on_chinese_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	TranslationServer.set_locale("zh")
