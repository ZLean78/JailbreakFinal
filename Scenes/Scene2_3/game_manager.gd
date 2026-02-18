extends Node

@onready var player = $"../Pausables/Player"
@onready var sharaka = $"../Pausables/Sharaka"
@onready var main_label = %MainLabel

var _reload_queued := false
var _switching := false


func _process(_delta):
	if is_instance_valid(player):
		check_player_dead()
	if GameStates.game_won:
		switch_scenes()
	else:
		check_enemy_dead()


func check_player_dead():
	if _reload_queued:
		return
	if not player.is_alive() or player.state_machine.is_in_state(&"Beaten"):
		_reload_queued = true
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()

func check_enemy_dead():
	if not is_instance_valid(sharaka):
		return
	if sharaka.state_machine.is_in_state(&"Beaten"):
		GameStates.game_won = true


func switch_scenes() -> void:
	if _switching:
		return
	_switching = true
	await (get_tree().create_timer(2.0).timeout)
	CinematicManager.play("chapter5")
