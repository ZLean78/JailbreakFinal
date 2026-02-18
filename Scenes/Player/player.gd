extends CharacterBody2D

var MeatScene=preload("res://Scenes/Meat/meat.tscn")

@export var max_health=0
@export var health:int=0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D
@onready var collision_shape2 = $CollisionShape2D2
@onready var drag_position = $Origin/DragPosition
@onready var origin = $Origin
@onready var sprite2 = $Origin/DragPosition/Sprite2D
@onready var light=$PointLight2D


enum States {idle,walking,crawl_idle,crawling,stealth,dead,waiting,waiting2,guard_walk,guard_idle}

var state=States.idle

var anim_states={
	States.idle:"idle",
	States.walking:"walk",
	States.crawl_idle:"crawl_idle",
	States.crawling:"crawl",
	States.stealth:"stealth",
	States.dead:"dead",
	States.waiting:"crawl_idle",
	States.waiting2:"idle",
	States.guard_walk:"GuardWalk",
	States.guard_idle:"GuardIdle"
}

var is_crawling=false
var can_crawl=true
var can_control=true

var last_animation=""
var cell=1

var SPEED = 150.0
const JUMP_VELOCITY = -400.0
var direction = Vector2()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var interaction_area_entered=false


func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if state == States.dead:
		return
	health = max(health - amount, 0)
	var ui := get_tree().get_first_node_in_group("ui")
	if ui and ui.has_method("update_health"):
		ui.update_health()


func _physics_process(_delta):
		
	
		
	#Vector para mover al jugador.
	direction = Input.get_vector("Left","Right","Up","Down")
	
	if !state==States.dead && can_control:
	
		#Mover al jugador.
		if direction:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
		
		#Orientar al jugador (orientar el sprite).
		if direction.y < 0:
			sprite.rotation = deg_to_rad(0)
			collision_shape2.rotation = deg_to_rad(0)
			origin.rotation=deg_to_rad(0)
		elif direction.y > 0:
			sprite.rotation = deg_to_rad(180)
			collision_shape2.rotation = deg_to_rad(180)
			origin.rotation=deg_to_rad(180)
		elif direction.x < 0:
			sprite.rotation = deg_to_rad(-90)
			collision_shape2.rotation = deg_to_rad(-90)
			origin.rotation=deg_to_rad(-90)
		elif direction.x > 0:
			sprite.rotation = deg_to_rad(90)
			collision_shape2.rotation = deg_to_rad(90)
			origin.rotation=deg_to_rad(90)
		else:
			sprite.rotation = sprite.rotation
			collision_shape2.rotation = collision_shape2.rotation
			origin.rotation=origin.rotation
			
			
		check_colliders()
		animate()
		move_and_slide()
		
		#for i in get_slide_collision_count():
			#var c=get_slide_collision(i)
			#if c.get_collider() is RigidBody2D:
				#if c.get_collider().is_dragged:
					#c.get_collider().apply_central_impulse(Vector2(1,0))
	
func _input(_event):
	if Input.get_vector("Left","Right","Up","Down"):
		if !GameStates.uniform_on:
			if !is_crawling:
				state=States.walking
			else:
				state=States.crawling
		else:
			state=States.guard_walk
	else:
		if !GameStates.uniform_on:
			if !is_crawling:
				state=States.idle
			else:
				state=States.crawl_idle
		else:
			state=States.guard_idle
	
	if Input.is_action_pressed("Crawl"):
		if !GameStates.uniform_on && can_crawl:
			is_crawling=!is_crawling
			if is_crawling:
				state=States.crawl_idle
			else:
				state=States.idle
		
	#if Input.is_action_just_pressed("Feed"):
		#var a_meat=MeatScene.instantiate()
		#get_tree().root.get_node("Yard1/Pieces").add_child(a_meat)	
		#a_meat.position=position


#Animar al jugador.
func animate():
	if velocity==Vector2.ZERO:
		if[States.idle,States.crawl_idle,States.dead,States.waiting,States.guard_idle].has(state):
			animation_player.play(anim_states[state])
	else:
		if[States.walking,States.crawling,States.stealth,States.guard_walk].has(state):
			animation_player.play(anim_states[state])
	
	
	#if state==States.crawling:
		#if direction != Vector2.ZERO:
			#animation_player.play("crawl")
		#else:
			#animation_player.play("crawl_idle")
	#else:
		#if GameStates.uniform_on:
			#if direction!=Vector2.ZERO:
				#animation_player.play("GuardWalk")
			#else:
				#animation_player.play("GuardIdle")
		#else:
			#if direction != Vector2.ZERO:
				#animation_player.play("walk")
			#else:
				#animation_player.play("walk_idle")
	
func check_colliders():
	if state==States.crawling:
		collision_shape.disabled=true
		collision_shape2.disabled=false
	else:
		collision_shape.disabled=false
		collision_shape2.disabled=true		
