class_name Rules extends Control


signal clicked_cancel

func _on_TextureButton_pressed():
	emit_signal("clicked_cancel")
