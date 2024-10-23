extends Duck


@onready var sprite_hungry: AnimatedSprite2D = %SpriteHungry

# Needs more food

func _ready() -> void:
	print_name("hungry duck")
	sprite_hungry.show()
