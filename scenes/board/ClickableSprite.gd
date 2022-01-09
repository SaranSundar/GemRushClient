class_name ClickableSprite extends Area2D

export var sprite_name: String

signal clicked_sprite(sprite_name)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		emit_signal("clicked_sprite", sprite_name)
