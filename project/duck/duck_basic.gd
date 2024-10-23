extends Duck


@onready var sprite_basic: AnimatedSprite2D = %SpriteBasic

# Base speed & hunger

func _ready() -> void:
	print_name("basic duck")
	sprite_basic.show()
	
