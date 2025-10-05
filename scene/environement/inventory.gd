extends Node

var inventory: Array = []

func add_item(item_name: String):
	if not has_item(item_name):
		inventory.append(item_name)
		InventoryUi.update_inventory()
		print(item_name, " add to inventory")
	else:
		print(item_name, " already in inventory")

func remove_item(item_name: String):
	if has_item(item_name):
		inventory.erase(item_name)
		InventoryUi.update_inventory()
		print(item_name, " out of inventory")

func has_item(item_name: String) -> bool:
	return item_name in inventory

func use_item(item_name: String):
	match item_name:
		"Key":
			print("You use the Key !")
			remove_item(item_name)
			InventoryUi.update_inventory()
		_:
			print("This Item is not usable !")

func drop_item(item_name: String, position: Vector2):
	remove_item(item_name)
	var drop_scene = preload("res://scene/environement/item/key.tscn")
	var dropped = drop_scene.instantiate()
	dropped.item_name = item_name
	dropped.position = position
	get_tree().current_scene.add_child(dropped)
