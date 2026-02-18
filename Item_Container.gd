extends Control

var item_name: String = "emptycell"

func name_item(i_name: String) -> void:
	item_name = i_name

func get_item_name() -> String:
	return item_name
