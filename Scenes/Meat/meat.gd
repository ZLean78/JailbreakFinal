class_name Meat
extends Node2D


@export var dog_1:Dog
@export var dog_2:Dog

@onready var eating_timer=$Timer

var is_eating_me=false
var amount=30


func _process(_delta):
	if dog_1==null || dog_2==null:
		check_dogs()
	
	if amount<=0:
		dog_1.meat=null
		dog_2.meat=null
		dog_1=null
		dog_2=null
		queue_free()

func check_dogs()->void:
	for a_dog in get_tree().get_nodes_in_group("dogs"):
		if dog_1==null and a_dog.meat==null:
			dog_1=a_dog
			a_dog.meat=self
		if dog_2==null and a_dog.meat==null:
			dog_2=a_dog
			a_dog.meat=self


func _on_area_2d_body_entered(body):
	if body.is_in_group("dogs"):
		is_eating_me=true


func _on_timer_timeout():
	if is_eating_me:
		amount-=1
		print(str(amount))
		eating_timer.start()
		
