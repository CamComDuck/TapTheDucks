extends Duck # Needs more food 

@onready var sprite_hungry: AnimatedSprite2D = %SpriteHungry

func _ready() -> void:
	print_name("Hungry Duck")
	
	_is_fast_type = false
	move_timer.wait_time = randf_range(2.1, 3)
	move_timer.start()
	
	#sprite_hungry.show()
	base_duck_sprite.modulate = Color(Color.GREEN)
