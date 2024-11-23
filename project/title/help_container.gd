extends TabContainer

var _is_remapping := false
var _action_to_remap : String = "null"
var _is_volume_being_changed := false
var _volume_sliders : Array[HSlider]
var _goose_red := 1.0
var _goose_green := 1.0
var _goose_blue := 1.0

@onready var master_percent := %MasterPercent as Label
@onready var music_percent := %MusicPercent as Label
@onready var sounds_percent := %SoundsPercent as Label

@onready var goose_texture := %GooseTexture as TextureRect
@onready var red_slider := %RedSlider as HSlider
@onready var green_slider := %GreenSlider as HSlider
@onready var blue_slider := %BlueSlider as HSlider

@onready var input_button_move_up := $Keybinds/VBoxContainer/HBoxContainer/InputButtonMoveUp as Button
@onready var input_button_move_down := $Keybinds/VBoxContainer/HBoxContainer4/InputButtonMoveDown as Button
@onready var input_button_interact_left := $Keybinds/VBoxContainer/HBoxContainer5/InputButtonInteractLeft as Button
@onready var input_button_interact_right := $Keybinds/VBoxContainer/HBoxContainer6/InputButtonInteractRight as Button
@onready var input_button_pause := $Keybinds/VBoxContainer/HBoxContainer7/InputButtonPause as Button

@onready var duck_basic := load("res://duck/duck_types/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/duck_types/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/duck_types/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/duck_types/duck_angry.tres") as DuckTypes

@onready var volume_vbox := $Volume/VBoxContainer as VBoxContainer
@onready var duck_grid_container := %GridContainer as GridContainer

func _ready() -> void:
	var volume_vbox_children = volume_vbox.get_children()
	for vbox_node in volume_vbox_children:
		if vbox_node is HBoxContainer:
			var volume_hbox_children = vbox_node.get_children()
			for hbox_node in volume_hbox_children:
				if hbox_node is HSlider:
					_volume_sliders.append(hbox_node)
					hbox_node.value = db_to_linear(AudioServer.get_bus_volume_db(_volume_sliders.size() - 1))
	
	var duck_info_grid : Array[Node] = duck_grid_container.get_children()
	var duck_types : Array[DuckTypes] = [duck_basic, duck_fast, duck_hungry, duck_angry]
	
	for node in duck_info_grid:
		if node is TextureRect or node is Label:
			for i in len(duck_types):
				if node.name.begins_with(duck_types[i].name):
					if node is TextureRect:
						node.modulate = duck_types[i].color
					elif node.name.ends_with("Points"):
						node.text = str(duck_types[i].point_value)
	
	#set_tab_icon(0, preload("res://game_overlay/icon_goose.png"))
	#set_tab_icon(1, POINTS)
	set_tab_icon(2, preload("res://duck/graphics/default_1.png"))
	set_tab_icon(3, preload("res://game_overlay/icon_goose.png"))
	
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
		button.text = "Press key to bind..."
		

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


func _on_red_slider_value_changed(value: float) -> void:
	_goose_red = value
	goose_texture.modulate = Color(_goose_red, _goose_green, _goose_blue)


func _on_green_slider_value_changed(value: float) -> void:
	_goose_green = value
	goose_texture.modulate = Color(_goose_red, _goose_green, _goose_blue)


func _on_blue_slider_value_changed(value: float) -> void:
	_goose_blue = value
	goose_texture.modulate = Color(_goose_red, _goose_green, _goose_blue)


func _on_save_color_button_pressed() -> void:
	GameInfo.goose_color = Color(_goose_red, _goose_green, _goose_blue)
	AudioController.play_sound_menu_click()
