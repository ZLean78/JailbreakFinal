extends Area2D

@export var player:CharacterBody2D=null
@export var rahiri:CharacterBody2D=null




func _input(_event):
	if Input.is_action_just_pressed("Interact"):
		if rahiri.can_activate:
			rahiri.active=true
			GameStates.game_won=true

func _on_body_entered(body):
	if body==player:
		rahiri.can_activate=true

func _on_body_exited(body):
	if body==player:
		rahiri.can_activate=false
