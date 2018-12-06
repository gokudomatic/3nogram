extends Area

export(Color,RGB) var color=Color(1,1,1) setget set_color

var material

signal cell_destroyed(source)
signal cell_created(position,axis)

var dead=false

func _ready():
	material=SpatialMaterial.new()
	$Cube.x_face=material
	$Cube.y_face=material
	$Cube.z_face=material

func set_color(value):
	if material!=null:
		color=value
		material.albedo_color=color

func destroy():
	dead=true
	get_tree().call_group("sfx","play","break")
	$Cube/AnimationPlayer.play("default")
	yield($Cube/AnimationPlayer, "animation_finished")
	self.queue_free()

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if dead:
		return
	if event is InputEventMouseButton and event.button_index==BUTTON_LEFT and event.is_pressed():
		if game_data.touch_mode==game_data.TOUCH_DESTROY:
			emit_signal("cell_destroyed",self)
		elif game_data.touch_mode==game_data.TOUCH_PAINT:
			get_tree().call_group("sfx","play","hint")
			set_color(game_data.build_color)
		elif game_data.touch_mode==game_data.TOUCH_BUILD:
			var v=click_normal.snapped(1)*2+translation
			var axis=0
			if abs(click_normal.y)>0.5:
				axis=1
			elif abs(click_normal.z)>0.5:
				axis=2
			emit_signal("cell_created",Vector3(round(v.x),round(v.y),round(v.z)),axis)