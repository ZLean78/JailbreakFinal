extends Node

var player: Node
var kaluga: Node
var hole: Node
var lever: Node
var collins_bar: ProgressBar
var kaluga_bar: ProgressBar

## Stun duration when player hits gas (seconds).
const PLAYER_STUN_DURATION: float = 1.5

## Stun duration when kaluga hits gas (seconds).
const KALUGA_STUN_DURATION: float = 6.0


func _ready():
	# Wait a frame to ensure all nodes are in the tree
	await get_tree().process_frame

	# Get node references from groups
	var players = get_tree().get_nodes_in_group("player")
	var kalugas = get_tree().get_nodes_in_group("kaluga")
	var holes = get_tree().get_nodes_in_group("hole")
	var levers = get_tree().get_nodes_in_group("lever")

	if players.size() > 0:
		player = players[0]
	if kalugas.size() > 0:
		kaluga = kalugas[0]
	if holes.size() > 0:
		hole = holes[0]
	if levers.size() > 0:
		lever = levers[0]

	collins_bar = get_tree().get_first_node_in_group("collins_bar")
	kaluga_bar = get_tree().get_first_node_in_group("kaluga_bar")

	if collins_bar and kaluga_bar and player and kaluga:
		print("Found health bars! Initializing...")
		# Set max values to match actual max health
		collins_bar.max_value = player.get_max_health()
		kaluga_bar.max_value = kaluga.get_max_health()
		# Set current values
		collins_bar.value = player.get_health()
		kaluga_bar.value = kaluga.get_health()
		print("Initial bars set: Player=", collins_bar.value, "/", collins_bar.max_value, ", Kaluga=", kaluga_bar.value, "/", kaluga_bar.max_value)
	else:
		print("ERROR: Could not find health bars or characters in entity_manager!")


func _start():
	if collins_bar and kaluga_bar:
		collins_bar.value = player.get_health()
		kaluga_bar.value = kaluga.get_health()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	# Skip if nodes aren't ready yet
	if not player or not kaluga or not hole:
		return

	# Check if gas hole affects player (must be activated AND player in area)
	if hole.is_activated and hole.is_body_in_area(player) and player.can_be_stunned():
		player.stun()

	# Check if gas hole affects Kaluga (must be activated AND kaluga in area)
	if hole.is_activated and hole.is_body_in_area(kaluga) and not kaluga.is_gas_stunned:
		# Trigger gas stun once when gas first hits
		kaluga.stun(KALUGA_STUN_DURATION)
		
	

	# Update health bars every frame
	check_energy()


func check_energy() -> void:
	if is_instance_valid(player) and is_instance_valid(kaluga) and collins_bar and kaluga_bar:
		var player_health = player.get_health()
		var kaluga_health = kaluga.get_health()
		if player_health != collins_bar.value:
			collins_bar.value = player_health
		if kaluga_health != kaluga_bar.value:
			kaluga_bar.value = kaluga_health
