extends TabContainer

var _goose_red : float
var _goose_green : float
var _goose_blue : float

@onready var duck_grid_container := %GridContainer as GridContainer
@onready var duck_basic := load("res://duck/duck_types/duck_basic.tres") as DuckTypes
@onready var duck_fast := load("res://duck/duck_types/duck_fast.tres") as DuckTypes
@onready var duck_hungry := load("res://duck/duck_types/duck_hungry.tres") as DuckTypes
@onready var duck_angry := load("res://duck/duck_types/duck_angry.tres") as DuckTypes
@onready var frozen_duck_texture := %FrozenDuckTexture as TextureRect

@onready var goose_texture := %GooseTexture as TextureRect
@onready var red_slider := %RedSlider as HSlider
@onready var green_slider := %GreenSlider as HSlider
@onready var blue_slider := %BlueSlider as HSlider

@onready var point_input_box := %PointInputBox as SpinBox

func _ready() -> void:
	set_tab_icon(0, preload("res://game_overlay/icon_goose.png"))
	set_tab_icon(1, preload("res://duck/graphics/default_1.png"))
	set_tab_icon(2, preload("res://game_overlay/icon_exit.png"))
	
	_goose_red = GameInfo.goose_color.r
	red_slider.value = _goose_red
	_goose_green = GameInfo.goose_color.g
	green_slider.value = _goose_green
	_goose_blue = GameInfo.goose_color.b
	blue_slider.value = _goose_blue
	goose_texture.modulate = Color(_goose_red, _goose_green, _goose_blue)
	GameInfo.goose_color = Color(_goose_red, _goose_green, _goose_blue)
	
	point_input_box.value = GameInfo.points_to_win
	
	frozen_duck_texture.modulate = GameInfo.frozen_duck_color
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


func update_menu_labels() -> void:
	set_tab_title(0, tr("GOOSE_COLOR_HEADING"))
	set_tab_title(1, tr("HOW_TO_PLAY_HEADING"))
	set_tab_title(2, tr("EXIT_MENU_HEADER"))
	

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


func _on_point_input_box_value_changed(value: int) -> void:
	GameInfo.points_to_win = value
	AudioController.play_sound_menu_click()


func _on_random_color_button_pressed() -> void:
	AudioController.play_sound_menu_click()
	_goose_red = randf_range(0, 1)
	red_slider.value = _goose_red
	_goose_green = randf_range(0, 1)
	green_slider.value = _goose_green
	_goose_blue = randf_range(0, 1)
	blue_slider.value = _goose_blue
	goose_texture.modulate = Color(_goose_red, _goose_green, _goose_blue)
	GameInfo.goose_color = Color(_goose_red, _goose_green, _goose_blue)
	
