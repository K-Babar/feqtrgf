extends CharacterBody2D
class_name Npc
signal dialogue_exited


@export var  speed = 30.0

var current_state = IDLE



var dir = Vector2.RIGHT
var start_pos
@export_file("*.json") var dialogue_file
var is_roaming = true 
var is_chatting = false
var is_following = false
var is_mouse = false
var player
var player_in_chat_zone = false


enum {
	IDLE,
	NEW_DIR,
	MOVE	
}

func _ready():
	randomize()
	start_pos = position


func _process(delta: float) -> void:
	#if current_state == 0 or current_state == 1:
	$AnimatedSprite2D.play("default")
	#elif current_state == 2 and !is_chatting:
	#	$AnimatedSprite2D.play("chat")
	if is_roaming:
		match current_state:
			
			IDLE:
				pass
			NEW_DIR:
				dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT])
			MOVE:
				move(delta)
	if Input.is_action_just_pressed("ui_accept"):

		$dialogue.start()
		is_roaming =false
		is_chatting = true

	if Input.is_action_just_pressed("clicked") && is_mouse:
		$dialogue.start()
		is_roaming =false
		is_chatting = true


func choose(array):
	array.shuffle()
	return array.front()


func move(delta):
	if !is_chatting:
		position += dir * speed * delta
		
		





func _on_chat_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):

		player =body 
		player_in_chat_zone = true
func _on_chat_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("dialogue_exited")
		player_in_chat_zone = false
		

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 1, 1.5])

	$Timer.start()
	current_state = choose([IDLE, NEW_DIR, MOVE])
	

func _on_dialogue_dialogue_finished() -> void:
	$dialogue.dialogue_is_active = false
	is_chatting = false 
	is_roaming = true


func _on_chat_detection_mouse_shape_entered(shape_idx: int) -> void:
	is_mouse =true


func _on_chat_detection_mouse_shape_exited(shape_idx: int) -> void:
	is_mouse=false
