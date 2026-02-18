extends CharacterBody2D


var inc=0

const SPEED = 60.0
@export var type:int=0
@export var player:CharacterBody2D
@export var path:Path2D
@export var pathfollow:PathFollow2D
@export var hanging_area:Area2D=null

@export var alert_delay_with_uniform: float = 3.0

@onready var raycast: RayCast2D = $RayCast2D
@onready var game_manager: Node = (get_tree().current_scene.get_node_or_null("GameManager") if get_tree() else null)

var _uniform_suspicion_time: float = 0.0
var _alert_emitted: bool = false
#@onready var animation_player = $AnimationPlayer
#@onready var raycast = $RayCast2D
#@onready var raycast2 = $RayCast2D2
#@onready var raycast3 = $RayCast2D3
#@onready var game_manager=%GameManager
#@onready var light_node=$LightNode
#@onready var cone=$LightNode/Cone

@onready var animation_player=$AnimationPlayer

enum States{washing,loading,unloading,hanging,unhanging,to_washer,to_tender,to_sink}
var state=null


func _ready() -> void:
	# Ensure working prisoners start their loop.
	# (The previous `_init()` used `==` by mistake and had no effect.)
	if state == null:
		if type == 1:
			state = States.washing
		elif type == 2:
			state = States.unloading



func _physics_process(delta):
	check_view(delta)
	check_states(delta)
	animate()

func check_view(delta: float) -> void:
	# Working prisoners can spot the player and trigger the global alert state.
	# We keep the same uniform behavior as guards: immediate alert if no uniform,
	# and delayed alert if the uniform is on.
	if _alert_emitted or GameStates.alert_state:
		return
	if !is_instance_valid(player) or !is_instance_valid(raycast):
		return
	
	raycast.force_raycast_update()
	var sees_player := raycast.is_colliding() and raycast.get_collider() == player
	
	if sees_player:
		if !GameStates.uniform_on:
			_emit_alert()
			return
		_uniform_suspicion_time += delta
		if _uniform_suspicion_time >= alert_delay_with_uniform:
			_emit_alert()
	else:
		_uniform_suspicion_time = 0.0

func _emit_alert() -> void:
	_alert_emitted = true
	if is_instance_valid(game_manager):
		game_manager.emit_signal("alert_state")
		return
	# Fallback if `current_scene` isn't set for some reason.
	if get_tree() and is_instance_valid(get_tree().current_scene):
		var gm := get_tree().current_scene.get_node_or_null("GameManager")
		if is_instance_valid(gm):
			gm.emit_signal("alert_state")


func check_states(delta):
	if type==1:
		if state==States.to_washer || state==States.to_sink:
			#rotation=90
			pathfollow.progress+=SPEED*delta
		elif state==States.washing:
			velocity=Vector2.ZERO
			#rotation=180.0
			var direction=Vector2.ZERO
			position=position+direction
			if get_tree()!=null:
				await(get_tree().create_timer(3.0).timeout)
				state=States.to_washer
		elif state==States.loading:
			velocity=Vector2.ZERO
			#rotation=90.0
			var direction=Vector2.ZERO
			position=position+direction
			if get_tree()!=null:
				await(get_tree().create_timer(2.0).timeout)
				state=States.to_sink
				
	elif type==2:
		if state==States.to_washer || state==States.to_tender:
			#rotation=90
			pathfollow.progress+=SPEED*delta
		elif state==States.unloading:
			velocity=Vector2.ZERO
			#rotation=90.0
			var direction=Vector2.ZERO
			position=position+direction
			if get_tree()!=null:
				await(get_tree().create_timer(2.0).timeout)
				state=States.to_tender
			
		elif state==States.hanging:
			velocity=Vector2.ZERO
			#rotation=0.0
			var direction=Vector2.ZERO
			position=position+direction
			if get_tree()!=null:
				await(get_tree().create_timer(2.0).timeout)
				state=States.to_washer
		elif state==States.unhanging:
			velocity=Vector2.ZERO
			#rotation=0.0
			var direction=Vector2.ZERO
			position=position+direction
			if get_tree()!=null:
				await(get_tree().create_timer(2.0).timeout)
				state=States.to_washer
	
func animate()->void:
	if state==States.to_tender:
		animation_player.play("walking_full")
	elif state==States.to_washer:
		if type==1:
			animation_player.play("walking_full")
		elif type==2:
			if hanging_area.touch%2==0:
				animation_player.play("walking_full")
			elif hanging_area.touch%2!=0:
				animation_player.play("walking_empty")
	elif state==States.to_sink:
		animation_player.play("walking_empty")
	elif state==States.loading:
		animation_player.play("hanging_clothes")
	elif state==States.unloading:
		animation_player.play("unloading")
	elif state==States.hanging:
		animation_player.play("hanging_clothes")
	elif state==States.unhanging:
		animation_player.play("unhanging")
	elif state==States.washing:
		animation_player.play("washing")
