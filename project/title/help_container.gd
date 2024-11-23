extends TabContainer

var _is_remapping := false
var _action_to_remap : String = "null"

@onready var input_button_move_up: Button = $Keybinds/VBoxContainer/HBoxContainer/InputButtonMoveUp
@onready var input_button_move_down: Button = $Keybinds/VBoxContainer/HBoxContainer4/InputButtonMoveDown
@onready var input_button_interact_left: Button = $Keybinds/VBoxContainer/HBoxContainer5/InputButtonInteractLeft
@onready var input_button_interact_right: Button = $Keybinds/VBoxContainer/HBoxContainer6/InputButtonInteractRight


func _ready() -> void:
	_update_keybind_labels(true)
	
	
func _input(event : InputEvent) -> void:
	if _is_remapping:
		if (
			event is InputEventKey or 
			(event is InputEventMouseButton and event.pressed)
		):
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
