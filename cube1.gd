tool
extends Area

export(Color,RGB) var color=Color(1,1,1) setget set_color
export(Color,RGB) var marked_color=Color(1,1,1) setget set_marked_color

export(bool) var marked=false setget set_marked

export(int,-1,9) var number_x=-1 setget set_number_x
export(int,"Normal","Circle","Square") var mode_x=0 setget set_mode_x
export(int,-1,9) var number_y=-1 setget set_number_y
export(int,"Normal","Circle","Square") var mode_y=0 setget set_mode_y
export(int,-1,9) var number_z=-1 setget set_number_z
export(int,"Normal","Circle","Square") var mode_z=0 setget set_mode_z

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _input_event(camera, event, pos, normal, shape):
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed):
		set_marked(not marked)

func set_number(value,i):
	$CubeMesh.get_surface_material(i).set_shader_param("number",value)
	
func set_mode(value,i):
	$CubeMesh.get_surface_material(i).set_shader_param("mode",value)

func set_number_x(value):
	number_x=value
	set_number(value,0)

func set_mode_x(value):
	mode_x=value
	set_mode(value,0)

func set_number_y(value):
	number_y=value
	set_number(value,1)

func set_mode_y(value):
	mode_y=value
	set_mode(value,1)

func set_number_z(value):
	number_z=value
	set_number(value,2)

func set_mode_z(value):
	mode_z=value
	set_mode(value,2)

func set_color(value):
	color=value
	for i in range(3):
		$CubeMesh.get_surface_material(i).set_shader_param("color",value)

func set_marked_color(value):
	marked_color=value
	for i in range(3):
		$CubeMesh.get_surface_material(i).set_shader_param("marked_color",value)

func set_marked(value):
	marked=value
	for i in range(3):
		$CubeMesh.get_surface_material(i).set_shader_param("marked",value)
