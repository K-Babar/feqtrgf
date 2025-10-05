extends Camera2D

@export var target: NodePath
@export var smoothing_speed: float = 5.0

@onready var player = get_node(target)

func _ready() -> void:
	make_current()  



func _process(delta):
	if player:
		global_position = global_position.lerp(player.global_position, smoothing_speed * delta)
