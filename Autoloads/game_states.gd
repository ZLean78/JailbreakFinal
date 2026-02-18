extends Node

const SAVE_PATH := "save_game.dat"

var checkpoint=-1
var has_blue_key=false
var has_yellow_key=false
var has_red_key=false
var has_white_key=false
var has_book=true
var has_map=false
var has_pen=false
var has_mask=false
var has_acid=false
var acid_applied=false
var has_uniform=false
var uniform_on=false
var mask_on=false
var has_wax=false
var first_aid=0
var meat_can=0
var meat_can_amount=0
var player_has_made_noise=false
var alert_state=false
var has_letter1=false
var has_letter2=false
var game_won=false
var has_essential_medicine=false

func _get_save_dict() -> Dictionary:
	return {
		"checkpoint": var_to_str(checkpoint),
		"haspen": var_to_str(has_pen),
		"hasbook": var_to_str(has_book),
		"hasmask": var_to_str(has_mask),
		"hasacid": var_to_str(has_acid),
		"acidapplied": var_to_str(acid_applied),
		"hasuniform": var_to_str(has_uniform),
		"haswax": var_to_str(has_wax),
		"firstaid": var_to_str(first_aid)
	}

func save_to_file() -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Error: Could not open save file for writing")
		return false
	file.store_line(JSON.stringify(_get_save_dict()))
	file.flush()
	file.close()

	var verify_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if verify_file != null:
		var file_size = verify_file.get_length()
		verify_file.close()
		if file_size > 0:
			return true

	print("Error: Save verification failed")
	return false

#func delete_save_file() -> bool:
	#if not FileAccess.file_exists(SAVE_PATH):
		#return true
	#var dir := DirAccess.open("user://")
	#if dir == null:
		#print("Error: Could not open user directory to delete save file")
		#return false
	#var err := dir.remove(SAVE_PATH)
	#if err != OK:
		#print("Error: Could not delete save file")
		#return false
	#return true


func reset_game_state() -> void:
	checkpoint = -1
	has_blue_key = false
	has_yellow_key = false
	has_red_key = false
	has_white_key = false
	has_book = true
	has_map = false
	has_pen = false
	has_mask = false
	has_acid = false
	acid_applied = false
	has_uniform = false
	uniform_on = false
	mask_on = false
	has_wax = false
	first_aid = 0
	meat_can = 0
	meat_can_amount = 0
	player_has_made_noise = false
	alert_state = false
	has_letter1 = false
	has_letter2 = false
	game_won = false
	has_essential_medicine = false
