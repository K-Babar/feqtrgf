extends Area2D


#@export var scene_to_load: PackedScene


#func _ready():
	#connect("area_entered", Callable(self, "_on_area_entered"))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var fade_manager = get_tree().get_first_node_in_group("FadeInOut")
		fade_manager.fade_to_scene("res://scene/levels/crypt/crypt.tscn")
