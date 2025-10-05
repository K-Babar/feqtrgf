extends VBoxContainer

var scroll_speed : float = 50.0

func _process(delta):
	position.y -= scroll_speed * delta
	
	if position.y + size.y < 0:
		get_tree().change_scene_to_file("res://scene/levels/title/title_scene.tscn")
