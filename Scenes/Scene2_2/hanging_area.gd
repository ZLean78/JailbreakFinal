extends Area2D

@export var prisoner:CharacterBody2D=null
@export var prisoner2:CharacterBody2D=null
@export var tender:StaticBody2D=null
var touch=0


func _on_body_entered(body):
	if body==prisoner || body==prisoner2:
		touch+=1
		if touch%2==0:
			body.state=body.States.unhanging
		else:
			body.state=body.States.hanging


func _on_body_exited(body):
	if body==prisoner || body==prisoner2:
		if touch%2==0:
			body.state=body.States.to_tender
		else:
			body.state=body.States.to_washer
