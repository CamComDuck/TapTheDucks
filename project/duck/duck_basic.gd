extends Duck # Base speed & hunger

@onready var sprite_basic: AnimatedSprite2D = %SpriteBasic

func _ready() -> void:
	print_name("Basic Duck")
	
	_is_fast_type = false
	move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()
	
	#sprite_basic.show()
	base_duck_sprite.modulate = Color(Color.YELLOW)
	
