extends CanvasLayer


@onready var fade_rect = $ColorRect
@onready var anim = $AnimationPlayer

func _ready():
	fade_rect.visible = false

signal transition_finished

func fade_to_scene(scene_path: String):
	get_tree().paused = true
	
	fade_rect.visible = true
	anim.play("fade_out")
	await anim.animation_finished
	get_tree().paused = false
	SoundManager.play_sound("portail")
	get_tree().change_scene_to_file(scene_path)
	
	anim.play("fade_in")
	await anim.animation_finished
	fade_rect.visible = false

	
	emit_signal("transition_finished")
