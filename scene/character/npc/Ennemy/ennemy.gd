extends "res://follower_smarter.gd"

class_name Enemy

## --- Nouveau signal pour les dégâts ---
#signal deal_damage(amount: int)
#
## --- Variables spécifiques à l'ennemi ---
#@export var damage_amount: int = 5
#
#func _ready() -> void:
	## On appelle le _ready() du parent pour garder le comportement d'origine
	#super._ready()
#
#func _on_proximity_too_close_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Player"):
		## On arrête le suivi comme avant
		#is_following = false
		#
		## --- Nouveau comportement : infliger des dégâts ---
		#emit_signal("deal_damage", damage_amount)
		#
		## (Optionnel) tu peux ajouter une animation d’attaque ici :
		## $AnimatedSprite2D2.play("attack")
