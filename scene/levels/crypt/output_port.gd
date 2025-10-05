extends Area2D


func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		var fade_manager = get_tree().get_first_node_in_group("FadeInOut")
		fade_manager.fade_to_scene("res://scene/main.tscn")
