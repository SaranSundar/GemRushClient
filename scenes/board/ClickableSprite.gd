class_name ClickableSprite extends Sprite

export var sprite_name: String

signal clicked_sprite(sprite_name)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == BUTTON_LEFT:
		var pos = position
		if Rect2(pos, texture.get_size()).has_point(event.position): # added this
			emit_signal("clicked_sprite", sprite_name)
			get_tree().set_input_as_handled() # if you don't want subsequent input callbacks to respond to this input
