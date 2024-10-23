extends Duck

@onready var sprite_fast: AnimatedSprite2D = %SpriteFast

# Moves faster

func _ready() -> void:
	print_name("fast duck")
	sprite_fast.show()
