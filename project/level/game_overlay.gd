extends Control

@onready var points_label := $PointsLabel as Label
@onready var game_end_container := $GameEndContainer as VBoxContainer
@onready var game_end_label := $GameEndContainer/GameEndLabel as Label

func _physics_process(_delta: float) -> void:
	points_label.text = str(ResourceTracker.points)


func game_end(is_win : bool) -> void:
	if is_win:
		game_end_label.text = "You win!"
	else:
		game_end_label.text = "You lose!"
		
	game_end_container.position.x = 384 - (game_end_container.size.x / 2)
	game_end_container.position.y = 384 - (game_end_container.size.y / 2)
	game_end_container.show()
