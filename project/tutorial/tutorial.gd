extends Node2D

signal tutorial_finished

@onready var animation_player := %AnimationPlayer as AnimationPlayer

func _ready() -> void:
	$Ice.hide()
	animation_player.play("tutorial")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	var tween_fade_out : Tween = create_tween()
	tween_fade_out.tween_property(self, "modulate", Color(1, 1, 1, 0), 1)
	await tween_fade_out.finished
	tutorial_finished.emit()
	queue_free()
