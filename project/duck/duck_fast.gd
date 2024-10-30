extends Duck # Moves faster

@onready var sprite_fast := %SpriteFast

func _ready() -> void:
	print_name("Fast Duck")
	
	_is_fast_type = true
	move_timer.wait_time = randf_range(1, 2)
	move_timer.start()
	
	#sprite_fast.show()
	base_duck_sprite.modulate = Color(Color.ORANGE)
