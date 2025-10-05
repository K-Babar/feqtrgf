extends Area2D

@onready var anim = $AnimatedSprite2D
@onready var gate_collision = $StaticBody2D/CollisionGate


func _ready():
	anim.play("close")
	connect("body_entered", _on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		if Inventory.has_item("Key"):
			anim.play("open")
			gate_collision.set_deferred("disabled", true)
			Inventory.use_item("Key")
		else:
			print("the Gate is close you need a key")
