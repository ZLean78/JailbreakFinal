class_name Player
extends Character



func handle_input(_delta:float)->void:
	var direction=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	direction.normalized()
	velocity=direction*speed
	#Si presionamos saltar y el sprite está en el suelo.
	if Input.is_action_just_pressed("jump") and sprite_on_floor():
		#pasamos al estado saltar.
		state=State.JUMP
		#Sin esta línea, que levanta es sprite en position.y==-1, no se puede saltar, 
		#porque sprite_is_on_floor() retorna verdadero.
		character_sprite.position.y=-1
		sprite_velocity=-JUMP_FORCE
	if Input.is_action_just_pressed("attack") and sprite_on_floor():
		state=State.ATTACK
	if Input.is_action_just_pressed("attack") and !sprite_on_floor():
		state=State.JUMPKICK




			
