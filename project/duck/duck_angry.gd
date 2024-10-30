extends Duck # Combination of Fast + Hungry ducks

@onready var sprite_angry: AnimatedSprite2D = %SpriteAngry

func _ready() -> void:
	print_name("Angry Duck")
	
	
	_is_fast_type = true
	move_timer.wait_time = randf_range(1, 2)
	move_timer.start()
	
	#sprite_angry.show()
	base_duck_sprite.modulate = Color(Color.RED)
