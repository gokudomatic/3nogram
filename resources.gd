extends Node

const textures=[
	preload("res://textures/0.png"),
	preload("res://textures/1.png"),
	preload("res://textures/2.png"),
	preload("res://textures/3.png"),
	preload("res://textures/4.png"),
	preload("res://textures/5.png"),
	preload("res://textures/6.png"),
	preload("res://textures/7.png"),
	preload("res://textures/8.png"),
	preload("res://textures/9.png")
]

const tex_circle=preload("res://textures/circle.png")
const tex_square=preload("res://textures/square.png")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_number_texture(num):
	if num==-1 or num>9:
		return null
	else:
		return textures[num]
