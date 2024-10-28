extends Duck

@onready var sprite_fast: AnimatedSprite2D = %SpriteFast

# Moves faster

func _ready() -> void:
	_is_fast_type = true
	move_timer.wait_time = randf_range(1, 2)
	move_timer.start()
	print_name("fast duck")
	#sprite_fast.show()
	base_duck_sprite.modulate = Color(Color.ORANGE)
