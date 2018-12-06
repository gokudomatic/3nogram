tool
extends Area

export(Color) var color=Color(0,0,1) setget set_color

signal value_changed(value)

var dragged=false

func _ready():
	$MeshInstance.set_surface_material(0,SpatialMaterial.new())
	pass

func set_color(value):
	if has_node("MeshInstance"):
		color=value
		$MeshInstance.get_surface_material(0).albedo_color=color

func _input(event):
	if dragged:
		if event is InputEventMouseButton and event.button_index==BUTTON_LEFT and !event.is_pressed():
			game_data.is_interacting_gui=false
			dragged=false
		elif event is InputEventMouseMotion:
			
			var camera=get_viewport().get_camera()
			var projection=camera.project_ray_normal(event.position)
			
			#calculate first vector
			var v_handler0=self.global_transform.origin-camera.global_transform.origin
			var v_handler = v_handler0.normalized()
			var v_relative_diff=projection-v_handler*v_handler.dot(projection)
			var v_diff=v_relative_diff*v_handler0.length()
			
			#calculate vector on axis
			var axis=(self.global_transform.origin-self.get_parent().global_transform.origin).normalized()
			var diff=int(axis.dot(v_diff)/2)
			
			if diff!=0:
				emit_signal("value_changed",diff)

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index==BUTTON_LEFT:
		dragged=event.is_pressed()
		game_data.is_interacting_gui=event.pressed
