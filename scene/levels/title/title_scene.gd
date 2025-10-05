extends Node2D

func _ready():
	SoundManager.play_music("titleMusic")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/credit/credits.tscn")
