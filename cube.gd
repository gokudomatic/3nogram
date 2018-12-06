extends Spatial

var x_face setget set_x_face
var y_face setget set_y_face
var z_face setget set_z_face

var normal_color=Color(0.7,0.7,0.7,1)
var marked_color=Color(1,0.3,0.3,1)
var maybe_color=Color(0.8,0.3,1,1)

var material_class=preload("res://cube_material.tres")

func _ready():
	set_x_face(material_class.duplicate())
	set_y_face(material_class.duplicate())
	set_z_face(material_class.duplicate())
	var resources=get_node("/root/resources")
	x_face.set_shader_param("tex_square",resources.tex_square)
	x_face.set_shader_param("tex_circle",resources.tex_circle)
	x_face.set_shader_param("color",normal_color)
	x_face.set_shader_param("marked_color",marked_color)
	x_face.set_shader_param("maybe_color",maybe_color)
	y_face.set_shader_param("tex_square",resources.tex_square)
	y_face.set_shader_param("tex_circle",resources.tex_circle)
	y_face.set_shader_param("color",normal_color)
	y_face.set_shader_param("marked_color",marked_color)
	y_face.set_shader_param("maybe_color",maybe_color)
	z_face.set_shader_param("tex_square",resources.tex_square)
	z_face.set_shader_param("tex_circle",resources.tex_circle)
	z_face.set_shader_param("color",normal_color)
	z_face.set_shader_param("marked_color",marked_color)
	z_face.set_shader_param("maybe_color",maybe_color)
	pass

func set_x_face(value):
	x_face=value
	$BrokenCube.set_surface_material(1,x_face)
	$"BrokenCube.001".set_surface_material(0,x_face)
	$"BrokenCube.002".set_surface_material(1,x_face)
	$"BrokenCube.003".set_surface_material(0,x_face)
	$"BrokenCube.004".set_surface_material(2,x_face)
	$"BrokenCube.005".set_surface_material(1,x_face)
	$"BrokenCube.006".set_surface_material(1,x_face)
	$"BrokenCube.007".set_surface_material(1,x_face)

func set_y_face(value):
	y_face=value
	$BrokenCube.set_surface_material(2,y_face)
	$"BrokenCube.001".set_surface_material(2,y_face)
	$"BrokenCube.002".set_surface_material(2,y_face)
	$"BrokenCube.003".set_surface_material(2,y_face)
	$"BrokenCube.004".set_surface_material(0,y_face)
	$"BrokenCube.005".set_surface_material(0,y_face)
	$"BrokenCube.006".set_surface_material(2,y_face)
	$"BrokenCube.007".set_surface_material(2,y_face)

func set_z_face(value):
	z_face=value
	$BrokenCube.set_surface_material(0,z_face)
	$"BrokenCube.001".set_surface_material(1,z_face)
	$"BrokenCube.002".set_surface_material(0,z_face)
	$"BrokenCube.003".set_surface_material(1,z_face)
	$"BrokenCube.004".set_surface_material(1,z_face)
	$"BrokenCube.005".set_surface_material(2,z_face)
	$"BrokenCube.006".set_surface_material(0,z_face)
	$"BrokenCube.007".set_surface_material(0,z_face)
