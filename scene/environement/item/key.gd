extends Area2D

@export var item_name: String = "Key"

var can_pick = false
var player_ref

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		can_pick = true
		player_ref = body

func _on_body_exited(body):
	if body == player_ref:
		can_pick = false
		player_ref = null

func _process(delta):
	if can_pick and Input.is_action_just_pressed("ui_accept"):
		Inventory.add_item(item_name)
		queue_free()
