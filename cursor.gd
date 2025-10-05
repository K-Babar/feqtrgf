extends Node

# Load the custom images for the mouse cursor.
var cursor_default = load("res://ART/Cursor/sprite_0.png")
var cursor_clicked = load("res://ART/Cursor/sprite_1.png")

func _process(delta):
	if Input.is_action_pressed("clicked"):
		Input.set_custom_mouse_cursor(cursor_clicked, Input.CURSOR_ARROW)
	else:
		Input.set_custom_mouse_cursor(cursor_default, Input.CURSOR_ARROW)
