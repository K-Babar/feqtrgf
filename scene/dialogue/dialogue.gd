extends Control

signal dialogue_finished

@export_file("*.json") var d_file#pour renomer tous les fichier mis dans la variable
var dialogue = []
var current_dialogue_id = 0
var dialogue_is_active =false
var can_accept_input: bool = true  # pour gérer le cooldown
func _ready():
	$NinePatchRect.hide()

func start():
	if dialogue_is_active :
		
		return
	if !get_parent().player_in_chat_zone:
		return
	dialogue_is_active = true
	$NinePatchRect.show()
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()

#on extrait le dialogue qui provient du fichier dialogue.json 
func load_dialogue():
	var file_path = get_parent().dialogue_file
	if file_path == null or file_path == "":
		push_warning("Aucun fichier de dialogue assigné à ce NPC")
		return []
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content
	
	


func _input(event: InputEvent) -> void:
	if !dialogue_is_active or !can_accept_input:
		return
	if !get_parent().player_in_chat_zone:
		return
	if (event.is_action_released("ui_accept")) || ( Input.is_action_just_pressed("clicked") && get_parent().is_mouse): #FUCK IDK why i am this bad but well it is workish
		next_script()
		can_accept_input = false   # on bloque l'input
		$Timer.start(1)          # on lance le timer (demi-seconde)
	

		
func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):

		dialogue_is_active = false 
		
		$NinePatchRect.hide()
		emit_signal("dialogue_finished")

		
	else : 

		$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name']
		$NinePatchRect/Text.text = dialogue[current_dialogue_id]['text']
	


func _on_timer_timeout() -> void:
	can_accept_input = true


func _on_npc_dialogue_exited() -> void:
	dialogue = []
	current_dialogue_id = 0
	dialogue_is_active =false
	can_accept_input = true  # pour gérer le cooldown
	$NinePatchRect.hide()
	
