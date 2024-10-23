extends Node2D

func _ready() -> void:
	var new_duck = load("res://duck/duck.tscn").instantiate()
	new_duck.set_script(load("res://duck/duck_basic.gd"))
	get_parent().add_child.call_deferred(new_duck)
	new_duck.global_position = Vector2i(200, 200)
