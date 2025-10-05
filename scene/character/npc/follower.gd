# Ally.gd
extends Npc
class_name Follower

@export var follow_player_when_near := true
@export var follow_distance := 4.0
@onready var path_follow = $Path2D/PathFollow2D
var last_direction := Vector2.ZERO
var idle := false
var path_speed = 100.0
func _ready() -> void:
	is_roaming = true
	is_chatting = false
	is_following = false
	start_pos = position
	idle = false

func _process(delta):
	# gestion des animations et logiques visuelles
	if velocity != Vector2.ZERO:
		_play_walk_animation(last_direction)
	else:
		# idle après TimerIdle
		if idle:
			_play_idle_animation(last_direction)
	if Input.is_action_just_pressed("ui_accept"):

		$dialogue.start()
		is_roaming =false
		is_chatting = true
	if Input.is_action_just_pressed("clicked") && is_mouse:
		$dialogue.start()
		is_roaming =false
		is_chatting = true	
	
func _physics_process(delta):
	# gestion du déplacement et des collisions
	velocity = Vector2.ZERO
	if follow_player_when_near and player and is_following:
		var v = player.global_position - global_position
		if v.length() > follow_distance:
			var direction = v.normalized()
			velocity = direction * speed
			last_direction = direction
			idle = false
			$TimerIdle.stop()
		else:
			if not idle:
				$TimerIdle.start()

	move_and_slide()


func _play_walk_animation(direction: Vector2) -> void:
	# On compare la direction dominante
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
# Quand TimerIdle expire, passe en anim "idle"
func _on_TimerIdle_timeout() -> void:
	idle = true
	$AnimatedSprite2D2.play("idle")


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
		player_in_chat_zone = false
		is_following = false
		emit_signal("dialogue_exited")


func _on_proximity_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_chat_zone = true
		is_following = follow_player_when_near


func _on_proximity_too_close_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_chat_zone = true
		is_following = follow_player_when_near


func _on_chat_detection_mouse_entered() -> void:
	is_mouse =true
	print('cacas')


func _on_chat_detection_mouse_exited() -> void:
	is_mouse =false
