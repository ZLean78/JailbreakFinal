extends Node2D

@export var enemy_body:=CharacterBody2D
@export var fov_angle:=60 	#Ángulo de visión total (grados).
@export var ray_length:=100	#Distancia máxima de visión.
@export var ray_count:=30	#Cuántos rayos se lanzan (más=más suave)
@export var collision_mask:=1 #Capa de colisión para paredes. No colisiona con balas (layer 8).

@onready var vision_logic := get_parent().get_node_or_null("RayCast2D") as RayCast2D

var polygon_points=[]

var enemy_direction

var enemy_state

const CONE_COLOR_PATROL := Color(0.2, 1.0, 1.0, 0.65) # bright cyan
const CONE_COLOR_CHASE := Color(1.0, 0.25, 0.25, 0.85) # bright red
const CONE_COLOR_RETURN := Color(0.2, 1.0, 1.0, 0.65) # bright cyan

func _ready():
	enemy_state=enemy_body.state
	enemy_direction=Vector2.RIGHT.rotated(enemy_body.rotation)
	rotation=enemy_direction.angle()
	
	# Make the cone pop in dark scenes: additive + unshaded "glow".
	if material == null:
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material = mat



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_vision_polygon()
	#get_angle()
	queue_redraw()
	
func update_vision_polygon():
	if !is_instance_valid(enemy_body):
		return
		
	polygon_points.clear()
	polygon_points.append(Vector2.ZERO)
	
	# Use the *actual* center RayCast2D direction as the cone facing.
	# This stays correct when the guard switches between:
	# - PATROL: raycasts use their authored direction (usually "up" / -Y)
	# - CHASE/RETURN: guard.gd rotates raycast nodes to face the objective
	var facing_angle := enemy_body.global_rotation
	if is_instance_valid(vision_logic):
		facing_angle = vision_logic.global_rotation + vision_logic.target_position.angle()

	#Calcular los rayos
	var start_angle=facing_angle-deg_to_rad(fov_angle)/2
	var angle_step=deg_to_rad(fov_angle)/ray_count
	
	for i in range(ray_count+1):
		var angle = start_angle+i*angle_step
		var dir = Vector2(cos(angle),sin(angle))
		var from_pos=global_position
		var to_pos=from_pos+dir*ray_length
		
		var space_state=get_world_2d().direct_space_state
		var query=PhysicsRayQueryParameters2D.create(from_pos,to_pos)
		query.collision_mask=collision_mask

		var result=space_state.intersect_ray(query)
		var hit_pos=result.position if result else to_pos
		
		polygon_points.append(to_local(hit_pos))
		
func get_angle():
	var target_position=vision_logic.target_position
	rotation=position.direction_to(target_position).angle()
	return rotation
	#var target_position=vision_logic.target_position
	#var direction=target_position-position
	#direction=direction.normalized()
	#var angle=atan2(direction.x,direction.y)
	#var angle_degrees=rad_to_deg(angle)
	#return angle_degrees
	
func _draw():
	if polygon_points.size()>=3:
		# Avoid triangulation failures by drawing a triangle fan manually.
		# Remove consecutive duplicate points to keep triangles valid.
		var pts := []
		for p in polygon_points:
			if pts.is_empty() or pts.back().distance_to(p) > 0.001:
				pts.append(p)
		if pts.size() < 3:
			return

		var cone_color: Color = CONE_COLOR_PATROL
		match enemy_body.state:
			enemy_body.State.PATROL:
				cone_color = CONE_COLOR_PATROL
			enemy_body.State.CHASE:
				cone_color = CONE_COLOR_CHASE
			enemy_body.State.RETURN:
				cone_color = CONE_COLOR_RETURN

		var origin = pts[0]
		for i in range(1, pts.size() - 1):
			draw_colored_polygon([origin, pts[i], pts[i + 1]], cone_color)
