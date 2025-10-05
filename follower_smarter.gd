extends Npc
class_name FollowerSmarter
var target_in_range: Node2D = null
@export var follow_player_when_near := true
@export var follow_distance := 4.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var target: Node2D = null
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var damage_amount = 15
@export var damage_interval: float = 1.0  # délai entre deux coups (en secondes)

var last_direction := Vector2.ZERO
var idle := false
var speed2 = 100
var target_priority =1
var Health =100
var is_attaking =false
func _ready() -> void:
	await get_tree().process_frame
	_play_idle_animation(Vector2.ZERO)
	is_roaming = true
	is_chatting = false
	is_following = true
	start_pos = position
	idle = false
	targeting()

func _process(delta):
	if Health<=0 :
		queue_free()
	if velocity != Vector2.ZERO:
		last_direction = velocity.normalized()
		_play_walk_animation(last_direction)
	elif idle:
		_play_idle_animation(last_direction)

	if Input.is_action_just_pressed("ui_accept"):
		$dialogue.start()
		is_roaming = false
		is_chatting = true
	if Input.is_action_just_pressed("clicked") && is_mouse:
		$dialogue.start()
		is_roaming =false
		is_chatting = true



func _physics_process(delta: float) -> void:
	target_priority = PriorityTarget()

	# Nous utilisons maintenant target (plutôt que "player") pour décider de suivre
	if target and is_following:
		if not is_instance_valid(target):
			targeting()
			return

		var target_pos: Vector2 = target.global_position
		# met à jour la cible du NavigationAgent si nécessaire
		if nav_agent.target_position != target_pos:
			nav_agent.target_position = target_pos

		# si nous sommes déjà arrivés
		if nav_agent.is_navigation_finished() or global_position.distance_to(target_pos) < follow_distance:
			velocity = Vector2.ZERO
			move_and_slide()
			return

		# sinon on calcule la prochaine position
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		var direction: Vector2 = (next_pos - global_position).normalized()
		velocity = direction * speed2

		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

		
# --- Gestion du ciblage ---
func targeting():
	if target_priority == 1:
		is_attaking = false
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() == 0:
			target = null
			return
		target = players[0]
		player = target

	elif target_priority == 2:
		is_attaking = true
		var players = get_tree().get_nodes_in_group("TargetEnemy")
		if players.size() == 0:
			target = null
			return
		target = players[0]
		player = target

	# --- Animation ---
	if is_attaking:  # <-- Correction ici (remplacement de "it" par "if")
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


func _play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			$AnimatedSprite2D2.play("right_walk")
		else:
			$AnimatedSprite2D2.play("left_walk")
	else:
		if direction.y > 0:
			$AnimatedSprite2D2.play("front_walk")
		else:
			$AnimatedSprite2D2.play("back_walk")


func _play_idle_animation(direction: Vector2) -> void:
	$AnimatedSprite2D2.play("idle")
func _on_TimerIdle_timeout() -> void:
	idle = true
	_play_idle_animation(last_direction)

# --- Zones de proximité et dialogue ---
func _on_chat_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_chat_zone = true
		is_following = false

func _on_chat_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_chat_zone = false
		is_following = false
		emit_signal("dialogue_exited")

func _on_proximity_too_close_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_following = false

func _on_proximity_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		is_following = follow_player_when_near

func _on_proximity_too_close_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_following = follow_player_when_near


func _on_chat_detection_mouse_entered() -> void:
	is_mouse = true
	

func _on_chat_detection_mouse_exited() -> void:
	is_mouse = false
func take_damage(damage : int):
	Health = Health - damage
	
	
func check_all_characters():
	var root = get_tree().current_scene  # récupère la scène active
	var characters = []

	# Parcours récursif de tous les noeuds
	for node in root.get_children():
		characters += _get_characters_recursive(node)

	# Vérifie les groupes pour chaque character
	for char in characters:
		print("Character :", char.name)
		if char.is_in_group("enemies"):
			print("-> est dans le groupe enemies")
		if char.is_in_group("allies"):
			print("-> est dans le groupe allies")
		# tu peux ajouter d'autres groupes ici

# Fonction récursive pour parcourir tous les enfants
func _get_characters_recursive(node):
	var chars = []
	if node is CharacterBody2D:
		chars.append(node)
	for child in node.get_children():
		chars += _get_characters_recursive(child)
	return chars
func PriorityTarget() -> int:
	var root = get_tree().current_scene
	
	#print(node)
	# Vérifie si un TargetEnemy est présent
	for node in root.get_children():
		
		if _has_node_type_recursive(node, "TargetEnemy"):
			return 2

	# Vérifie si un Player est présent
	for node in root.get_children():
		if _has_node_type_recursive(node, "Player"):
			return 1

	return 0  # rien trouvé

# Fonction récursive pour vérifier le type du noeud par nom ou classe
func _has_node_type_recursive(node, type_name: String) -> bool:
	if node.name == type_name or node.is_in_group(type_name):
		return true
	for child in node.get_children():
		if _has_node_type_recursive(child, type_name):
			return true
	return false


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("TargetEnemy"):
		target_in_range = body
		is_attaking = true
		print("Follower attaque :", body.name)

		if not has_node("DamageTimer"):
			var timer = Timer.new()
			timer.name = "DamageTimer"
			timer.wait_time = damage_interval  # <--- important !
			timer.one_shot = false
			timer.autostart = false
			add_child(timer)
			timer.connect("timeout", Callable(self, "_on_follower_damage_timer_timeout"))
			timer.start()  # <--- ici on le démarre
		else:
			var timer = $DamageTimer
			if not timer.is_connected("timeout", Callable(self, "_on_follower_damage_timer_timeout")):
				timer.connect("timeout", Callable(self, "_on_follower_damage_timer_timeout"))
			timer.wait_time = damage_interval  # <--- au cas où
			timer.start()  # <--- redémarre aussi le timer existant

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body == target_in_range:
		target_in_range = null
		is_attaking = false
		print("Follower a arrêté d’attaquer.")
		if has_node("DamageTimer"):
			$DamageTimer.stop()
func _on_follower_damage_timer_timeout() -> void:
	if target_in_range and target_in_range.has_method("take_damage"):
		target_in_range.take_damage(damage_amount)
