extends Duck 


@onready var sprite_hungry: AnimatedSprite2D = %SpriteHungry

# Needs more food

func _ready() -> void:
	_is_fast_type = false
	move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()
	print_name("hungry duck")
	#sprite_hungry.show()
	base_duck_sprite.modulate = Color(Color.GREEN)
