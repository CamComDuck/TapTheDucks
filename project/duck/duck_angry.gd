extends Duck

# Combination of Fast + Hungry ducks
@onready var sprite_angry: AnimatedSprite2D = %SpriteAngry

func _ready() -> void:
	print_name("Angry duck")
	sprite_angry.show()
