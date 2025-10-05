extends FollowerSmarter

@export var damage_amount2: int = 15  # ← Ajoute cette ligne, valeur par défaut

var is_mouse_on = false
@onready var anim_enemy: AnimatedSprite2D = $AnimatedSprite2DEnemy

var order = Global.attack_order
func _ready() -> void:
	super._ready()
	$AnimatedSprite2D2.play("default")

	# Connexion pour sélection manuelle
	$ChatDetection.connect("input_event", Callable(self, "_on_chat_detection_input_event"))

	# Timer de dégâts
	if not has_node("DamageTimer"):
		var timer = Timer.new()
		timer.name = "DamageTimer"
		timer.wait_time = damage_interval
		timer.one_shot = false
		timer.autostart = false
		add_child(timer)
		timer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))
	else:
		$DamageTimer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))

	# Choisit une première cible
	select_target()


func _physics_process(delta: float) -> void:
	# Si pas de cible valide -> en choisir une
	#if not is_instance_valid(target):
		#select_target()
		#return
	select_target()

	order = Global.attack_order
	if is_mouse_on && order:
		
		var groups = get_groups()
		print("Node", name, "appartient aux groupes :")
		for g in groups:
			print(" -", g)
		add_to_group("TargetEnemy")

	# Déplacement vers la cible
	if target and is_following:
		var target_pos = target.global_position

		if nav_agent.target_position != target_pos:
			nav_agent.target_position = target_pos

		# Vérifie si arrivé à portée
		if nav_agent.is_navigation_finished() or global_position.distance_to(target_pos) < follow_distance:
			velocity = Vector2.ZERO
			move_and_slide()
			return

		# Continue à suivre
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity = direction * speed2
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

	# Mort si plus de vie
	if Health <= 0:
		kill()


# --- Sélection d'une cible ---
func select_target() -> void:

	var allies = get_tree().get_nodes_in_group("Ally")
	var players = get_tree().get_nodes_in_group("Player")
	
	# S'assure qu'on ne se choisit pas soi-même
	allies = allies.filter(func(a): return a != self)
	allies = allies.filter(func(a): return !a.is_ko)
	if allies.size() > 0 :

		# Choisit un Ally aléatoire en priorité
		target = allies[0]
		#print(target.get_groups())
		#print(name, " attaque en priorité :  ", target.name, "(Ally)")
	elif players.size() > 0:

		# Si aucun Ally, alors vise Player
		target = players[randi() % players.size()] # ← au cas où plusieurs players
		#print(name, " attaque par défaut :", target.name, "(Player)")
	else:
		target = null
		#print(name, "n’a trouvé aucune cible.")



# --- Quand un corps entre dans la zone d’attaque ---
func _on_proximity_too_close_body_entered(body: Node2D) -> void:
	if body == target:
		is_following = false
		target_in_range = body
		$DamageTimer.start()
		#print(name, "attaque", body.name)


# --- Quand un corps sort de la zone ---
func _on_proximity_too_close_body_exited(body: Node2D) -> void:
	if body == target_in_range:
		target_in_range = null
		is_following = true
		$AnimatedSprite2D2.play("default")
		$DamageTimer.stop()



# --- Application des dégâts ---
func _on_damage_timer_timeout() -> void:
	if target_in_range and target_in_range.has_method("take_damage"):
		target_in_range.take_damage(damage_amount2)
		#print(name, "inflige", damage_amount2, "dégâts à", target_in_range.name)


func take_damage(damage: int) -> void:
	Health -= damage
	#print(name, "a pris", damage, "dégâts. Santé restante :", Health)
	if Health <= 0:
		kill()


func kill():
	queue_free()


# --- Gestion du clic de sélection ---
func _on_chat_detection_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var player_node = get_tree().get_first_node_in_group("Player")
		print('tuez moi')
		if player_node and player_node.get("attaque_order"):
			print('caca')

			if not is_in_group("target"):
				add_to_group("target")
				print(name, "ajouté au groupe target !")


func _on_targetable_area_mouse_entered() -> void:
	is_mouse_on = true


func _on_targetable_area_mouse_exited() -> void:
	

	is_mouse_on = false
func _play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_enemy.play("right_walk")
		else:
			anim_enemy.play("left_walk")
	else:
		if direction.y > 0:
			anim_enemy.play("front_walk")
		else:
			anim_enemy.play("back_walk")

func _play_idle_animation(direction: Vector2) -> void:
	anim_enemy.play("idle")


func _on_chat_detection_mouse_entered() -> void:
	pass # Replace with function body.
