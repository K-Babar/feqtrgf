extends Node2D


func _ready():
	$StaticBody2D/Lake.play("default")
	$Player/Camera2D.enabled = false
	$Camera2D2.enabled = true
	
