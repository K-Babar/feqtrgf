extends CanvasLayer

@onready var item_list = $Panel/VBoxContainer
@onready var context_menu = $ContextMenu
var selected_item: String = ""
var is_open = false

@onready var button_use = $ButtonUse/VBoxContainer/Label
@onready var use = $ButtonUse
 

func _ready():
	hide()
	context_menu.hide()
	button_use.hide()
	use.hide()

func _process(delta):
	if Input.is_action_just_pressed("ui_inventory"):
		toggle_inventory()
		
	if Global.attack_order:
		toggle_order_attaque()

func toggle_inventory():
	is_open = !is_open
	if is_open:
		show()
		update_inventory()
	else:
		hide()
		context_menu.hide()

func update_inventory():
	for child in item_list.get_children():
		child.queue_free()

	for item_name in Inventory.inventory:
		var button = Button.new()
		button.text = item_name
		button.connect("pressed", Callable(self, "_on_item_pressed").bind(item_name))
		item_list.add_child(button)

func _on_item_pressed(item_name: String):
	selected_item = item_name
	context_menu.position = get_viewport().get_mouse_position()
	context_menu.show()

func _on_use_pressed():
	if selected_item != "":
		Inventory.use_item(selected_item)
		update_inventory()
	context_menu.hide()

func _on_drop_pressed():
	if selected_item != "":
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			Inventory.drop_item(selected_item, player.global_position + Vector2(0, 16))
		update_inventory()
	context_menu.hide()


func _on_button_pressed():
	InventoryUi._on_use_pressed()


func _on_button_2_pressed():
	InventoryUi._on_drop_pressed()
	

func toggle_order_attaque():
	show()
	use.show()
	button_use.show()
	button_use.text = "ATTACK 1"
