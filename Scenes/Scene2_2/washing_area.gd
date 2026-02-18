extends Area2D

@export var prisoner:CharacterBody2D=null
@export var prisoner2:CharacterBody2D=null


func _on_body_entered(body):
	if body==prisoner || body==prisoner2:
		body.state=body.States.washing
	
