class_name UI
extends Control

var MeatScene=preload("res://Scenes/Meat/meat.tscn")
const HELP_INTERACT_TEXTURE := preload("res://Scenes/UI/HelpButtonE.png")

@onready var box_container=$BoxContainer
@onready var color_rect=$ColorRect
@onready var items_container=$BoxContainer/ItemsFlowContainer
@onready var options_container=$BoxContainer/VBoxContainer
@onready var text_area=$BoxContainer/TextAreaContainer/TextArea
@onready var player

@onready var mask=get_tree().get_first_node_in_group("mask")
@onready var suit=get_tree().get_first_node_in_group("suit")
@onready var wax=get_tree().get_first_node_in_group("wax")
@onready var acid=get_tree().get_first_node_in_group("acid")
@onready var file=get_tree().get_first_node_in_group("file")
@onready var label=%MainLabel
@onready var help_sprite=%HelpSprite
@onready var healthbar=$HealthBar
@onready var name_label=$Name
var _player_has_interaction_area := false
var _default_interact_prompt_active := false
var _was_interaction_area_entered := false

var _inventory_help_state := -1

var _help_hide_timer: Timer
var _help_snapshot_text: String = ""
var _help_snapshot_texture: Texture2D = null
var _help_observed_text: String = ""
var _help_observed_texture: Texture2D = null

var current_index=-1
var current_index2=-1
var UI_state=0
var was_inventory_open=false
var just_transitioned_to_options=false

func _is_settings_menu_open() -> bool:
	# The pause/settings menu is an autoload named "PauseMenu".
	# If settings is open, keep the help UI visible behind it (don't overwrite/clear it).
	var pause_layer := get_node_or_null("/root/PauseMenu")
	if pause_layer == null:
		return false
	var settings := pause_layer.get_node_or_null("SettingsMenu")
	return settings != null and settings.visible

func _ready():
	# Some scenes forget to assign the UI node to the "ui" group in the .tscn.
	# Bullets and other systems rely on this group to refresh the health bar.
	add_to_group("ui")
	if get_tree().root.get_child(4).name=="Scene2_3"||get_tree().root.get_child(4).name=="Scene2_5":
		player=get_tree().get_nodes_in_group("player")[0]
	else:
		player=%Player
	_player_has_interaction_area = _has_property(player, &"interaction_area_entered")
	_setup_help_timer()
	_help_observed_text = label.text
	_help_observed_texture = help_sprite.texture
		
	update_items()
	update_health()

func _setup_help_timer() -> void:
	if is_instance_valid(_help_hide_timer):
		return
	_help_hide_timer = Timer.new()
	_help_hide_timer.one_shot = true
	_help_hide_timer.wait_time = 3.0
	_help_hide_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_help_hide_timer)
	_help_hide_timer.timeout.connect(_on_help_hide_timeout)

func _arm_help_timeout_if_needed() -> void:
	if not is_instance_valid(_help_hide_timer):
		return
	# Only auto-hide when something is actually being shown.
	if label.text == "" and help_sprite.texture == null:
		_help_hide_timer.stop()
		return
	_help_snapshot_text = label.text
	_help_snapshot_texture = help_sprite.texture
	_help_hide_timer.stop()
	_help_hide_timer.start()

func _observe_help_changes() -> void:
	# External scripts often set MainLabel/HelpSprite directly.
	# Whenever they change to a non-empty value, restart the 3s auto-hide timer.
	if label.text != _help_observed_text or help_sprite.texture != _help_observed_texture:
		_help_observed_text = label.text
		_help_observed_texture = help_sprite.texture
		_arm_help_timeout_if_needed()

func _on_help_hide_timeout() -> void:
	# Clear only if the currently shown help is still the one we snapshotted.
	if label.text == _help_snapshot_text and help_sprite.texture == _help_snapshot_texture:
		help_sprite.texture = null
		label.text = ""
	_default_interact_prompt_active = false

func update_health():
	if is_instance_valid(player) and is_instance_valid(healthbar):
		healthbar.max_value = _get_player_max_health()
		healthbar.value = _get_player_health()

func _has_property(obj: Object, prop_name: StringName) -> bool:
	if obj == null:
		return false
	for prop in obj.get_property_list():
		if prop.name == prop_name:
			return true
	return false

func _player_is_not_interacting() -> bool:
	if not is_instance_valid(player):
		return false
	if not _player_has_interaction_area:
		return true
	return not player.interaction_area_entered

func _get_player_health() -> int:
	if not is_instance_valid(player):
		return 0
	if player is BaseCharacter:
		return player.get_health()
	return player.health

func _get_player_max_health() -> int:
	if not is_instance_valid(player):
		return 0
	if player is BaseCharacter:
		return player.get_max_health()
	return player.max_health

func _heal_player(amount: int) -> void:
	if not is_instance_valid(player) or amount <= 0:
		return
	if player is BaseCharacter:
		if player.health_component:
			player.health_component.heal(amount)
		return
	player.health = min(player.health + amount, player.max_health)

# Helper function to update item selection visuals
func update_item_selection():
	for container in items_container.get_children():
		var item_texture = container.get_child(0)
		var container_index = container.get_index()
		var is_selected = (container_index == current_index)
		var current_texture_path = ""
		if item_texture.texture:
			current_texture_path = item_texture.texture.resource_path
		
		# Check all possible texture combinations and update accordingly
		var texture_pairs = [
			["res://Scenes/UI/emptycell.png", "res://Scenes/UI/emptycell_selected.png"],
			["res://Scenes/UI/book.png", "res://Scenes/UI/book_selected.png"],
			["res://Scenes/UI/pen.png", "res://Scenes/UI/pen_selected.png"],
			["res://Scenes/UI/bluekey.png", "res://Scenes/UI/bluekey_selected.png"],
			["res://Scenes/UI/yellowkey.png", "res://Scenes/UI/yellowkey_selected.png"],
			["res://Scenes/UI/redkey.png", "res://Scenes/UI/redkey_selected.png"],
			["res://Scenes/UI/whitekey.png", "res://Scenes/UI/whitekey_selected.png"],
			["res://Scenes/UI/gasMask.png", "res://Scenes/UI/gasMaskSelected.png"],
			["res://Scenes/UI/suit.png", "res://Scenes/UI/suit_selected.png"],
			["res://Scenes/UI/wax.png", "res://Scenes/UI/wax_selected.png"],
			["res://Scenes/UI/acid.png", "res://Scenes/UI/acid_selected.png"],
			["res://Scenes/UI/first_aid.png", "res://Scenes/UI/first_aid_selected.png"],
			["res://Scenes/UI/meat_can.png", "res://Scenes/UI/meat_can_selected.png"]
		]
		
		for pair in texture_pairs:
			if current_texture_path == pair[0] || current_texture_path == pair[1]:
				if is_selected:
					item_texture.texture = load(pair[1])
				else:
					item_texture.texture = load(pair[0])
				break
	
func _process(_delta):
	# Reset transition flag at start of each frame (after _input has been called)
	just_transitioned_to_options = false
	
	var is_inventory_open = color_rect.visible && box_container.visible
	var inventory_just_opened: bool = is_inventory_open and not was_inventory_open
	
	# Detect when inventory opens and focus first item
	if is_inventory_open && !was_inventory_open && UI_state == 0:
		current_index = 0
		update_item_selection()
	
	# Detect when inventory closes and reset state
	if !is_inventory_open && was_inventory_open:
		UI_state = 0
		current_index = -1
		current_index2 = -1
		# Clear all option highlights
		for option in options_container.get_children():
			option.get_child(0).label_settings.font_color=Color.WHITE
	
	var settings_open := _is_settings_menu_open()
	if not settings_open:
		# Default interaction prompt: show once when we ENTER an interaction area.
		if is_instance_valid(player) and _player_has_interaction_area:
			var in_area: bool = player.interaction_area_entered

			# If someone else overwrote the default prompt, don't treat it as ours anymore.
			if _default_interact_prompt_active:
				var is_still_default_text: bool = (label.text == "INTERACTUAR" or label.text == "")
				var is_still_default_icon: bool = (help_sprite.texture == HELP_INTERACT_TEXTURE or help_sprite.texture == null)
				if not (is_still_default_text and is_still_default_icon):
					_default_interact_prompt_active = false

			# Rising edge: just entered an interaction area.
			if in_area and not _was_interaction_area_entered:
				var changed := false
				# Only fill missing pieces; do not override existing custom help.
				if help_sprite.texture == null:
					help_sprite.texture = HELP_INTERACT_TEXTURE
					changed = true
				if label.text == "":
					label.text = "INTERACTUAR"
					changed = true
				if changed:
					_default_interact_prompt_active = true

			# Leaving all interaction areas: allow showing again next time.
			if (not in_area) and _was_interaction_area_entered:
				# If the default prompt is still on screen, clear it immediately.
				if _default_interact_prompt_active:
					if label.text == "INTERACTUAR" and (help_sprite.texture == HELP_INTERACT_TEXTURE or help_sprite.texture == null):
						help_sprite.texture = null
						label.text = ""
				_default_interact_prompt_active = false

			_was_interaction_area_entered = in_area

		# Inventory help: show briefly (max 3s) on open or when UI_state changes.
		if is_inventory_open:
			if inventory_just_opened or _inventory_help_state != UI_state:
				_inventory_help_state = UI_state
				if UI_state == 0:
					help_sprite.texture = load("res://Scenes/UI/HelpKeys1.png")
					label.text = "MOVERSE,SELECCIONAR ÍTEM"
				elif UI_state == 1:
					help_sprite.texture = load("res://Scenes/UI/HelpKeys2.png")
					label.text = "MOVERSE,SELECCIONAR OPCIÓN,ATRÁS"
		else:
			_inventory_help_state = -1

	was_inventory_open = is_inventory_open

	# Always observe help changes (even while settings is open) so auto-hide applies everywhere.
	_observe_help_changes()

func update_items()->void:
	
	for item in items_container.get_children():
		item.get_child(0).texture=load("res://Scenes/UI/emptycell.png")
	
	
	if GameStates.has_book:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/book.png")
				break
	if GameStates.has_pen:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/pen.png")
				break
	if GameStates.has_mask:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/gasMask.png")
				if is_instance_valid(mask):
					mask.queue_free()
				break
	if GameStates.has_uniform:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/suit.png")
				if is_instance_valid(suit):
					suit.queue_free()
				break
	if GameStates.has_wax:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/wax.png")
				if is_instance_valid(wax):
					wax.queue_free()
				break
	if GameStates.has_acid:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/acid.png")
				if is_instance_valid(acid):
					acid.queue_free()
				break
	if GameStates.first_aid>0:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/first_aid.png")
				item.get_child(0).get_child(0).text=str(GameStates.first_aid)
				break
	if GameStates.meat_can>0:
		for item in items_container.get_children():
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/meat_can.png")
				item.get_child(0).get_child(0).text=str(GameStates.meat_can)
				break

	for item in items_container.get_children():
		if GameStates.has_blue_key:
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/bluekey.png")
				break
	for item in items_container.get_children():
		if GameStates.has_yellow_key:
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/yellowkey.png")
				break
	for item in items_container.get_children():
		if GameStates.has_red_key:
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/redkey.png")
				break
	for item in items_container.get_children():
		if GameStates.has_white_key:
			if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
				item.get_child(0).texture=load("res://Scenes/UI/whitekey.png")
				break
	
	
	if self.visible:
		for anoption in options_container.get_children():
			anoption.get_child(0).label_settings.font_color=Color.WHITE
		# Update item selection if inventory is visible
		if color_rect.visible && box_container.visible && UI_state == 0:
			update_item_selection()
	else:
		# Clear all selections when inventory is not visible
		for container in items_container.get_children():
			var item_texture = container.get_child(0)
			var texture_path = ""
			if item_texture.texture:
				texture_path = item_texture.texture.resource_path
			
			# Remove _selected from any selected textures
			if texture_path.ends_with("_selected.png"):
				var base_path = texture_path.replace("_selected.png", ".png")
				item_texture.texture = load(base_path)
		
		current_index = -1
		current_index2 = -1
		UI_state = 0
				
			
func _input(_event):
	if $ColorRect.visible && $BoxContainer.visible:
		
		
		if Input.is_action_pressed("ItemForward"):
			if self.visible==true:
				if UI_state==0:
					# Right navigation with row-based wrapping (6x2 grid: 0-11)
					# Row 1: indices 0-5, Row 2: indices 6-11
					# Wrap within the same row
					@warning_ignore("integer_division")
					var row = current_index / 6  # 0 for row 1, 1 for row 2
					var col = current_index % 6  # Column within row (0-5)
					col = (col + 1) % 6  # Move right, wrap to 0 if at column 5
					current_index = row * 6 + col
					update_item_selection()
				
		if Input.is_action_pressed("ItemBackward"):
			if self.visible==true:
				if UI_state==0:
					# Left navigation with row-based wrapping (6x2 grid: 0-11)
					# Row 1: indices 0-5, Row 2: indices 6-11
					# Wrap within the same row
					@warning_ignore("integer_division")
					var row = current_index / 6  # 0 for row 1, 1 for row 2
					var col = current_index % 6  # Column within row (0-5)
					col = (col - 1 + 6) % 6  # Move left, wrap to 5 if at column 0
					current_index = row * 6 + col
					update_item_selection()
				
		if Input.is_action_pressed("ItemUp"):
			if self.visible==true:
				if UI_state==0:
					# Up navigation in inventory (6x2 grid: 0-11)
					# Row 1: indices 0-5, Row 2: indices 6-11
					# If in row 2 (index >= 6), go to same column in row 1
					# If in row 1 (index < 6), wrap to same column in row 2
					if current_index >= 6:
						current_index -= 6
					else:
						current_index += 6
					update_item_selection()
				elif UI_state==1:
					if current_index2>0:
						current_index2-=1
					else:
						current_index2=3
					
					for an_option in options_container.get_children():
						if an_option.get_index()!=current_index2:
							an_option.get_child(0).label_settings.font_color=Color.WHITE
						else:
							an_option.get_child(0).label_settings.font_color=Color.YELLOW
		
		if Input.is_action_pressed("ItemDown"):
			if self.visible==true:
				if UI_state==0:
					# Down navigation in inventory (6x2 grid: 0-11)
					# Row 1: indices 0-5, Row 2: indices 6-11
					# If in row 1 (index < 6), go to same column in row 2
					# If in row 2 (index >= 6), wrap to same column in row 1
					if current_index < 6:
						current_index += 6
					else:
						current_index -= 6
					update_item_selection()
				elif UI_state==1:
					if current_index2<3:
						current_index2+=1
					else:
						current_index2=-1
				
					for an_option in options_container.get_children():
						if an_option.get_index()!=current_index2:
							an_option.get_child(0).label_settings.font_color=Color.WHITE
						else:
							an_option.get_child(0).label_settings.font_color=Color.YELLOW	
		
		if Input.is_action_pressed("Escape"):
			if self.visible:
				if UI_state==1:
					UI_state=0
					for option in options_container.get_children():
						option.get_child(0).label_settings.font_color=Color.WHITE
					# Reset to first item when going back to inventory navigation
					current_index = 0
					update_item_selection()
					
		
		if Input.is_action_pressed("Enter"):
			if self.visible:
				if UI_state==0:
					# Check if the selected item slot is not empty
					var selected_container = items_container.get_child(current_index)
					var selected_texture_path = ""
					if selected_container.get_child(0).texture:
						selected_texture_path = selected_container.get_child(0).texture.resource_path
					
					var is_empty = selected_texture_path == "res://Scenes/UI/emptycell.png" || selected_texture_path == "res://Scenes/UI/emptycell_selected.png"
					
					UI_state=1
					just_transitioned_to_options = true  # Flag to prevent Enter from propagating
					
					# If item slot is not empty, focus the first option
					if !is_empty:
						current_index2 = 0
						for an_option in options_container.get_children():
							if an_option.get_index() == 0:
								an_option.get_child(0).label_settings.font_color=Color.YELLOW
							else:
								an_option.get_child(0).label_settings.font_color=Color.WHITE
					else:
						# If empty, just set all options to white
						for an_option in options_container.get_children():
							an_option.get_child(0).label_settings.font_color=Color.WHITE
					
				elif UI_state==1 && !just_transitioned_to_options:
					for container in items_container.get_children():
						if container.get_child(0).texture==load("res://Scenes/UI/emptycell_selected.png"):
							text_area.text="Compartimento vacío."
						if container.get_child(0).texture==load("res://Scenes/UI/book_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								if !GameStates.has_pen:
									text_area.text="Libro: 'tiene un objeto oculto en su\nencuadernación.'"
									GameStates.has_pen=true		
									for item in items_container.get_children():
										if item.get_child(0).texture==load("res://Scenes/UI/emptycell.png"):
											item.get_child(0).texture=load("res://Scenes/UI/pen.png")
											break
								else:
									if !GameStates.has_map:
										text_area.text="Libro: 'aquí dice PÁRRAFO ILEGIBLE\nAPLÍQUESE ÁCIDO CÍTRICO.'"
									else:
										text_area.text=""
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								if !GameStates.has_pen:
									text_area.text="Libro: 'un libro. Debo examinarlo.'"
								else:
									if !GameStates.has_map:
										text_area.text="Libro: 'hay algo más en este libro.'"
									else:
										text_area.text=""	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Libro: 'no necesito equiparlo,\nbasta con tenerlo en mi inventario'."
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/pen_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Bolígrafo: llave disfrazada de bolígrafo.\nAbre los pasajes en las paredes\nque lucen diferente."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Bolígrafo: 'no necesito usarlo,\nbasta con tenerlo en mi inventario.'"	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Bolígrafo: 'no necesito equiparlo,\nbasta con tenerlo en mi inventario'."
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/bluekey_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave azul: abre todas las puertas de ese color."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Llave azul: 'no necesito usarla,\nbasta con tenerla en mi inventario.'"	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave azul: 'no necesito equiparla,\nbasta con tenerla en mi inventario'."
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/yellowkey_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave amarilla: abre todas las puertas de ese color."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Llave amarilla: 'no necesito usarla,\nbasta con tenerla en mi inventario.'"	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave amarilla: 'no necesito equiparla,\nbasta con tenerla en mi inventario'."
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/redkey_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave roja: abre todas las puertas de ese color."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Llave roja: 'no necesito usarla,\nbasta con tenerla en mi inventario.'"
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave roja: 'no necesito equiparla,\nbasta con tenerla en mi inventario'."
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/whitekey_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave blanca: abre todas las puertas de ese color."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Llave blanca: 'no necesito usarla,\nbasta con tenerla en mi inventario.'"	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Llave blanca: 'no necesito equiparla,\nbasta con tenerla en mi inventario'."
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/gasMaskSelected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Máscara antigás: protege contra el gas tóxico\ndel pasillo Oeste."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Máscara antigás: 'Debo equiparla para usarla.'"	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								if GameStates.has_mask:
									GameStates.mask_on=!GameStates.mask_on
									if GameStates.mask_on:
										label.text="Máscara antigás equipada."
										
									else:
										label.text="Máscara antigás desequipada."
										
								await(get_tree().create_timer(2.0).timeout)
								label.text=""
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/suit_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Uniforme de guardia: 'Usado junto con la pomada en mi inventario\nhace que los guardias no me distingan\n de uno de ellos por unos segundos'."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Uniforme de guardia: 'Debo equiparlo para usarlo.'"	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:
								if GameStates.has_wax && get_tree().get_root().get_child(1).name!="Scene2_3":
									if !player.state==player.States.crawling:
										GameStates.uniform_on=!GameStates.uniform_on
										if GameStates.uniform_on:
											player.sprite.texture=load("res://Resources/Textures/collinsGuardWalk.png")
											player.sprite.hframes=4
											player.sprite.vframes=1
											player.sprite.frame = min(1, max(0, (player.sprite.hframes * player.sprite.vframes) - 1))
										else:
											player.sprite.texture=load("res://Resources/Textures/collinsIdle.png")
											player.sprite.hframes=3
											player.sprite.vframes=1
											player.sprite.frame = min(1, max(0, (player.sprite.hframes * player.sprite.vframes) - 1))
									else:
										text_area.text="No puedo ponérmelo gateando."
								else:
									if get_tree().get_root().get_child(1).name=="Scene1":
										text_area.text="Tengo un problema, no soy nativo local.\nNecesito algo más para pasar por uno de ellos."
									else:
										text_area.text="No puedo usarlo aquí."	
						if container.get_child(0).texture==load("res://Scenes/UI/wax_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Pomada negra: 'al tenerla en mi inventario\ny seleccionar el uniforme,\npuedo pasar por un oficial nativo\ncon ella'."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								text_area.text="Pomada negra: 'debo tener el uniforme,\nen mi inventario y seleccionarlo\npara poder usarla.'"	
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Pomada negra: 'no necesito equiparla,\nbasta con tenerla en mi inventario\npara usarla con el uniforme'."
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						if container.get_child(0).texture==load("res://Scenes/UI/acid_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Ácido cítrico: 'debo usarlo para aplicarlo sobre el libro'."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								GameStates.acid_applied=true
							
								file.check_items()
								text_area.text="Ácido cítrico: ácido aplicado. Ve a\narchivo y mira\nla información."
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Ácido cítrico: 'no es para equipar,\nes para usar.'"
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
								
						if container.get_child(0).texture==load("res://Scenes/UI/first_aid_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Botiquín de primeros auxilios: recarga media barra de tu energía."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								if int(container.get_child(0).get_child(0).text)>0:
									var max_health := _get_player_max_health()
									var heal_amount := int(round(max_health * 0.5))
									_heal_player(heal_amount)
									update_health()
									GameStates.first_aid-=1
									update_items()
									container.get_child(0).get_child(0).text=str(GameStates.first_aid)
									if(GameStates.first_aid<=0):
										container.get_child(0).texture=load("res://Scenes/UI/emptycell.png")
										container.get_child(0).get_child(0).text=""
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Botiquín de primeros auxilios: 'no es para equipar,\nes para usar.'"
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
								
						if container.get_child(0).texture==load("res://Scenes/UI/meat_can_selected.png"):
							if options_container.get_child(0).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Carne con narcóticos. Esto debe ser lo que le dan a los perros\npara que detecten la droga."
							if options_container.get_child(1).get_child(0).label_settings.font_color==Color.YELLOW:
								if get_tree().root.get_node("Yard1")!=null:
									if int(container.get_child(0).get_child(0).text)>0:
										var a_meat=MeatScene.instantiate()
										get_tree().root.get_node("Yard1/MeatPieces").add_child(a_meat)	
										a_meat.position=player.position
										GameStates.meat_can_amount-=1
										if GameStates.meat_can_amount<=0:
											GameStates.meat_can-=1
											if GameStates.meat_can>0:
												GameStates.meat_can_amount=5
										if(GameStates.meat_can<=0):
											container.get_child(0).texture=load("res://Scenes/UI/emptycell.png")
											container.get_child(0).get_child(0).text=""
										update_items()
							if options_container.get_child(2).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text="Carne con narcóticos: 'no es para equipar,\nes para usar.'"
							if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
								text_area.text=""
						
						if options_container.get_child(3).get_child(0).label_settings.font_color==Color.YELLOW:	
							text_area.text=""
							file.get_node("CanvasLayer").visible=true
							file.get_node("CanvasLayer/MapTexture").visible=false
