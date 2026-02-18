extends RigidBody2D

@export var speed: float = 200.0
@export var damage: int = 10
@export var lifetime: float = 5.0

var direction: Vector2

@onready var timer = $Timer

func _ready():
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_timer_timeout)

	# Set up physics properties
	contact_monitor = true
	max_contacts_reported = 1
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	body_entered.connect(_on_collision)

	# Make bullet independent of parent transform (won't rotate with guard)
	top_level = true

	# Use the direction set by the shooter, not parent rotation
	set_direction(direction)

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	linear_velocity = direction * speed
	rotation = direction.angle()

func _on_timer_timeout():
	queue_free()

func _on_collision(body):
	print("Bullet collision with: ", body.name, " Groups: ", body.get_groups())
	if body.is_in_group("player"):
		print("Hit player! Applying damage: ", damage)
		# Deal damage to player
		if body.has_method("take_damage"):
			print("Using take_damage method")
			body.take_damage(damage)
		elif body.has_method("on_receive_damage"):
			# If using the character system
			print("Using on_receive_damage method")
			var hit_type = 0  # Normal damage
			body.on_receive_damage(damage, direction, hit_type)
		else:
			# Direct health modification for old player system
			print("Direct health modification")
			if body.get("health") != null:
				var old_health = int(body.get("health"))
				body.health = max(old_health - damage, 0)
				print("Health changed from ", old_health, " to ", body.health)
				# Update UI health bar
				var ui = get_tree().get_first_node_in_group("ui")
				if ui and ui.has_method("update_health"):
					ui.update_health()
					print("UI updated")
		queue_free()
	elif body.is_in_group("guards"):
		# Ignore collision with guards - don't destroy bullet
		print("Ignoring collision with guard")
		return
	else:
		# Hit any other collidable object (walls, obstacles, doors, desks, tilemaps, etc.)
		print("Hit collidable object, destroying bullet")
		queue_free()
