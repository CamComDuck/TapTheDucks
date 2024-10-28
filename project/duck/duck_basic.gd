extends Duck

@onready var sprite_basic: AnimatedSprite2D = %SpriteBasic

# Base speed & hunger

func _ready() -> void:
	_is_fast_type = false
	move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()
	print_name("basic duck")
	#sprite_basic.show()
	base_duck_sprite.modulate = Color(Color.YELLOW)
	
