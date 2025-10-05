extends Node2D


func _ready():
	SoundManager.play_music("backgroundMusic")
	$StaticBody2D/Lake.play("default")
	$Player/Camera2D.enabled = false
	$Camera2D2.enabled = true
	
