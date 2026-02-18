extends Control

@onready var UI1=$"../UI"
@onready var color_rect=$CanvasLayer/ColorRect
@onready var color_rect2=$CanvasLayer/ColorRect2
@onready var map_texture=$CanvasLayer/MapTexture
@onready var letter1_content=$CanvasLayer/Letter1Content
@onready var letter2_content=$CanvasLayer/Letter2Content
@onready var canvas_layer=$CanvasLayer

var item_index=0

func _ready():
	check_items()

func check_items():
	#Ocultar los contenidos.
	if map_texture.visible == true:
		map_texture.visible=false
	if letter1_content.visible == true:
		letter1_content.visible=false
	if letter2_content.visible == true:
		letter2_content.visible=false
	if color_rect2.visible == true:
		color_rect2.visible=false
		
	#Mostrar las etiquetas.	
	if GameStates.acid_applied:
		$CanvasLayer/ColorRect/MapLabel.visible=true
	if GameStates.has_letter1:
		$CanvasLayer/ColorRect/Letter1Label.visible=true
	else:
		$CanvasLayer/ColorRect/Letter1Label.visible=false
	if GameStates.has_letter2:
		$CanvasLayer/ColorRect/Letter2Label.visible=true
	else:
		$CanvasLayer/ColorRect/Letter2Label.visible=false

func _input(_event):

	var visible_items = get_visible_items()
	var max_index = visible_items.size() 
	
	
	
	if Input.is_action_pressed("ui_down"):
		if item_index<max_index:
			item_index+=1
		else:
			item_index=0
		if $CanvasLayer.visible:
			for i in visible_items.size():
				var item = visible_items[i]
				if i == item_index:
					item.label_settings.font_color = Color.YELLOW 
				else:
					item.label_settings.font_color = Color.WHITE
					
	if Input.is_action_pressed("ui_up"):
		if item_index>0:
			item_index-=1
		else:
			item_index=max_index
		if $CanvasLayer.visible:
			for i in visible_items.size():
				var item = visible_items[i]
				if i == item_index:
					item.label_settings.font_color = Color.YELLOW if i == item_index else Color.WHITE
				else:
					item.label_settings.font_color = Color.WHITE
	
	if Input.is_action_pressed("Enter"):
		if $CanvasLayer.visible:
			for i in visible_items.size():
				var item = visible_items[i]
				item.label_settings.font_color = Color.YELLOW if i == item_index else Color.WHITE
				if item.label_settings.font_color == Color.YELLOW:
					if item.is_in_group("map"):
						map_texture.visible=true
					if item.is_in_group("letter1"):
						letter1_content.visible=true
						color_rect2.visible=true
					if item.is_in_group("letter2"):
						letter2_content.visible=true
						color_rect2.visible=true
					if item.is_in_group("exit"):
						handle_exit()
	
					

func get_visible_items():
	var items = []
	for item in color_rect.get_children():
		if item.visible:
			items.append(item)
	return items

func handle_exit()->void:
	canvas_layer.visible=false		
	if GameStates.has_map:
		$CanvasLayer/ColorRect/MapLabel.visible = true
	if GameStates.has_letter1:
		$CanvasLayer/ColorRect/Letter1Label.visible = true
	if GameStates.has_letter2:
		$CanvasLayer/ColorRect/Letter2Label.visible = true
