extends Npc
class_name FollowerSmarter
var target_in_range: Node2D = null
@export var follow_player_when_near := true
@export var follow_distance := 4.0
@export var speed2 := 100
@export var Health := 50
@export var restime := 15

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D2
@onready var res_timer: Timer = $ResTimer
@onready var label: RichTextLabel = $RichTextLabel
@onready var attack_sprite: AnimatedSprite2D = $AttackSprite2D  # sprite d’attaque séparé
@export var  damage_interval = 1
var target: Node2D = null
var last_direction := Vector2.ZERO
var idle := false
var is_ko := false

var attack_mode := false   # true si le follower doit attaquer un ennemi

func _ready() -> void:
	label.text = ""
	await get_tree().process_frame
	_play_idle_animation(Vector2.ZERO)
	targeting()
	res_timer.connect("timeout", Callable(self, "_on_res_timer_timeout"))


func _process(delta: float) -> void:
	# --- Gestion KO ---
	if is_ko:
		label.text = str(int(round(res_timer.time_left)))
	else:
		label.text = ""

	## --- Orientation du sprite vers la cible pour l'attaque ---
	#if target and not is_ko and attack_mode:
		#_update_attack_orientation()

	# --- Animation marche/idle ---
	if not is_ko:
		if velocity != Vector2.ZERO:
			last_direction = velocity.normalized()
			_play_walk_animation(last_direction)
		elif idle:
			_play_idle_animation(last_direction)

func _physics_process(delta):
	var Enemie = get_tree().get_nodes_in_group("TargetEnemy")
	if Enemie == []:
		attack_mode =false
	else: 
		attack_mode =true
	if not is_ko and target and is_following:
		if not is_instance_valid(target):
			targeting()
			return

		var target_pos = target.global_position
		if nav_agent.target_position != target_pos:
			nav_agent.target_position = target_pos

		if nav_agent.is_navigation_finished() or global_position.distance_to(target_pos) < follow_distance:
			velocity = Vector2.ZERO
			move_and_slide()
			return

		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		velocity = direction * speed2
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

# --- Gestion du ciblage ---
func targeting():
	if attack_mode:
		# Mode attaque → chercher uniquement les ennemis
		var enemies = get_tree().get_nodes_in_group("TargetEnemy")
		if enemies.size() > 0:
			print('here')
			target = enemies[0]
			is_following = true
		else:
			target = null
	else:
		# Mode normal → suivre le joueur
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player = players[0]
			target = player
			is_following = true
		else:
			target = null
			is_following = false

# --- Animations ---
func _play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim_sprite.play("right_walk")
		else:
			anim_sprite.play("left_walk")
	else:
		if direction.y > 0:
			anim_sprite.play("front_walk")
		else:
			anim_sprite.play("back_walk")

func _play_idle_animation(direction: Vector2) -> void:
	anim_sprite.play("idle")

# --- KO ---
func ko(duration: float) -> void:
	if is_ko:
		return
	is_ko = true
	is_following = false
	anim_sprite.play("stun")
	res_timer.wait_time = duration
	res_timer.start()
	label.text = str(round(duration))

func _on_res_timer_timeout() -> void:
	is_ko = false
	is_following = true
	anim_sprite.play("default")
	label.text = ""

# --- Attaque orientée ---
func _on_proximity_too_close_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_chat_zone = true
		is_following = false

	if attack_mode and body.is_in_group("TargetEnemy"):
		is_following = false
		target = body
		_update_attack_orientation()
		if attack_sprite.has_animation("attack"):
			attack_sprite.play("attack")


func _on_chat_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_chat_zone = false
		is_following = false
		emit_signal("dialogue_exited")


func _on_proximity_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		is_following = true
		


func _on_proximity_too_close_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_following = true
		

	if body == target:
		target = null
		is_following = follow_player_when_near
		#attack_sprite.stop()
	targeting()
func _update_attack_orientation() -> void:
	if not target or not attack_sprite:
		return
	var direction = (target.global_position - global_position).normalized()
	var distance = 20
	attack_sprite.position = direction * distance
	attack_sprite.flip_h = direction.x < 0

# --- Dégâts ---
func take_damage(damage: int):
	Health -= damage
	if Health <= 0:
		ko(restime)

# --- Activation / désactivation du mode attaque ---
func set_attack_mode(state: bool) -> void:
	attack_mode = state
	targeting()
