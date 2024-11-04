extends Control

@onready var points_label := $PointsLabel as Label
@onready var game_end_container := $GameEndContainer as VBoxContainer
@onready var game_end_label := $GameEndContainer/GameEndLabel as Label
@onready var win_particles := $WinParticles as CPUParticles2D
@onready var lives_container := $LivesContainer as HBoxContainer
@onready var life := load("res://game_overlay/life.tscn") as PackedScene

func _physics_process(_delta: float) -> void:
	points_label.text = str(ResourceTracker.points)
	update_lives_label()

	
func update_lives_label() -> void:
	if lives_container.get_child_count() < ResourceTracker.lives:
		var new_life := life.instantiate() as TextureRect
		lives_container.add_child.call_deferred(new_life)

	elif lives_container.get_child_count() > ResourceTracker.lives and lives_container.get_child_count() > 0:
		lives_container.get_child(0).queue_free()


func game_end(is_win : bool) -> void:
	if is_win:
		game_end_label.text = "You win!"
		win_particles.emitting = true
	else:
		game_end_label.text = "You lose!"
		
	game_end_container.position.x = 384 - (game_end_container.size.x / 2)
	game_end_container.position.y = 384 - (game_end_container.size.y / 2)
	game_end_container.show()
