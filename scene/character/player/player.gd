extends CharacterBody2D
signal command_attack

@export var speed = 400 # HERE we set up the speed variable and it can be changed afterward 
var screen_size # Size of the game window.
@export var  Health = 100
var can_move = true
var order = false
func _ready():
	screen_size = get_viewport_rect().size #get the size of my screen bc the tuto said so




#code that i stole from the tutorial and changed
func _process(delta):
	#Global.attack_order = self.order
	if Input.is_action_just_pressed("attack_order"):
		order = true
		Global.attack_order = true
	if Input.is_action_just_released("attack_order"):
		order = false
	velocity = Vector2.ZERO # The player's movement vector.
	move_and_slide()
	if can_move:
		# --- Déplacements ---
		if Input.is_action_pressed("move_right"):
			SoundManager.play_sound("walk")
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			SoundManager.play_sound("walk")
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			SoundManager.play_sound("walk")
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			SoundManager.play_sound("walk")
			velocity.y -= 1

		# --- Normalisation et mouvement ---
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			position += velocity * delta
			position = position.clamp(Vector2.ZERO, screen_size)

			# --- Choix de l'animation en fonction de la direction ---
			if abs(velocity.x) > abs(velocity.y): 
				# Mouvement horizontal prioritaire
				if velocity.x > 0:
					$AnimatedSprite2D.animation = "RightWalk"
				else:
					$AnimatedSprite2D.animation = "LeftWalk"
			else:
				# Mouvement vertical prioritaire
				if velocity.y > 0:
					$AnimatedSprite2D.animation = "DownWalk"
				else:
					$AnimatedSprite2D.animation = "UpWalk"

			$AnimatedSprite2D.play()
		else:
			# Pas de mouvement → animation arrêtée
			$AnimatedSprite2D.stop()
		if Input.is_action_just_pressed("ui_accept"):
			#die()
			pass
		if Health <=0 : 
			die()
func die() -> void:
	# Joue l'animation de mort
	$AnimatedSprite2D.animation = "die"
	can_move=false
	# Configure et démarre le timer de mort
	$TimerDeath.wait_time = 4
	$TimerDeath.start()
	
	# Attend la fin du timer avant de changer de scène
	await $TimerDeath.timeout
	
	# Change de scène une fois le timer terminé
	get_tree().change_scene_to_file("res://scene/levels/title/title_scene.tscn")

func _on_timer_death_timeout() -> void:
	$TimerDeath.wait_time = 5 
	$TimerDeath.start()
func take_damage(damage : int):
	print(Health)
	Health = Health - damage
