extends CharacterBody2D

var inc=0

const SPEED = 60.0
@export var type:int=0
@export var player:CharacterBody2D
@export var path:Path2D
@export var pathfollow:PathFollow2D
@onready var remote_transform: RemoteTransform2D = (
	pathfollow.get_node_or_null("RemoteTransform2D") as RemoteTransform2D
	if is_instance_valid(pathfollow) else null
)
@onready var animation_player = $AnimationPlayer
@onready var raycast = $RayCast2D
@onready var raycast2 = $RayCast2D2
@onready var raycast3 = $RayCast2D3
@onready var game_manager=%GameManager
@onready var sprite=$Sprite2D
enum State{PATROL,CHASE,RETURN,CHECK_CELLS}
var state=State.PATROL
#@onready var light_node=$LightNode
#@onready var cone=$LightNode/Cone
#@onready var mark1 = $"../../../Marks/Mark1"
#@onready var mark2 = $"../../../Marks/Mark2"
#@onready var mark3 = $"../../../Marks/Mark3"
#@onready var mark4 = $"../../../Marks/Mark4"
#@onready var mark5 = $"../../../Marks/Mark5"
#@onready var path4 = $"../../../Pausable/Paths/Path2D4"
#@onready var path_follow4 = $"../../../Pausable/Paths/Path2D4/PathFollow2D"
#@onready var remote_transform4 = $"../../../Pausable/Paths/Path2D4/PathFollow2D/RemoteTransform2D"
#@onready var label=%MainLabel



func _physics_process(delta):	
	check_states(delta)	
	animate()
	check_view()
	
func check_states(delta):
	match state:
		State.PATROL:			
			_set_remote_transform_active(true)
			if is_instance_valid(path):
				inc+=delta*SPEED
				pathfollow.progress=inc
		State.CHASE:
			_set_remote_transform_active(false)
			if is_instance_valid(player):
				look_at(player.position)
				player.state=player.States.dead
		State.RETURN:
			pass
		State.CHECK_CELLS:
			pass		
			
func check_view():
	if is_instance_valid(player):
		if (raycast.get_collider()==player|| 
		raycast2.get_collider()==player || 
		raycast3.get_collider()==player):
			if !GameStates.uniform_on:
				state = State.CHASE
				_set_remote_transform_active(false)
				player.state=player.States.dead
			else:
				await(get_tree().create_timer(3.0).timeout)
				if (raycast.get_collider()==player|| 
				raycast2.get_collider()==player || 
				raycast3.get_collider()==player):
					#label.text="¿¡Quién eres tú!?"
					state = State.CHASE
					_set_remote_transform_active(false)
					player.state=player.States.dead
		#else:
			#if raycast.get_collider()!=null:
				#cone.scale.y=raycast.get_collision_point().y+light_node.global_position.y
				

func animate():
	animation_player.play("Walk")


func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		state=State.CHASE
		_set_remote_transform_active(false)
		if is_instance_valid(player):
			look_at(player.global_position)

func _set_remote_transform_active(active: bool) -> void:
	# Scene2_4 patrol movement is driven by a RemoteTransform2D on the PathFollow2D.
	# When the guard switches to CHASE, we must detach it or it will overwrite
	# the guard's rotation each frame (preventing `look_at` from taking effect).
	if !is_instance_valid(remote_transform):
		return
	if active:
		if remote_transform.remote_path.is_empty():
			remote_transform.remote_path = remote_transform.get_path_to(self)
	else:
		if !remote_transform.remote_path.is_empty():
			remote_transform.remote_path = NodePath("")
