extends Area

export(Color,RGB) var color=Color(1,1,1) setget set_color
export(Color,RGB) var marked_color=Color(1,1,1) setget set_marked_color
export(Color,RGB) var revealed_color=Color(1,1,1) setget set_revealed_color

export(int,"Normal","Marked","Maybe") var marked=0 setget set_marked
export(bool) var solid=false
export(bool) var found_x=false setget set_found_x
export(bool) var found_y=false setget set_found_y
export(bool) var found_z=false setget set_found_z
export(bool) var reveal=false setget set_reveal

export(bool) var hint_visible_x=true setget set_hint_visible_x
export(int,-1,9) var number_x=-1 setget set_number_x
export(int,"Normal","Circle","Square") var mode_x=0 setget set_mode_x
export(bool) var hint_visible_y=true setget set_hint_visible_y
export(int,-1,9) var number_y=-1 setget set_number_y
export(int,"Normal","Circle","Square") var mode_y=0 setget set_mode_y
export(bool) var hint_visible_z=true setget set_hint_visible_z
export(int,-1,9) var number_z=-1 setget set_number_z
export(int,"Normal","Circle","Square") var mode_z=0 setget set_mode_z

signal cell_destroyed(source,is_mistake)
signal cell_resisted(source)
signal cell_marked(source)
signal cell_hint_toggled(source,axis)

var broken=false
var dead=false

func _ready():
	set_number_x(number_x)
	set_number_y(number_y)
	set_number_z(number_z)

func set_number_x(value): 
	if has_node("Cube"):
		number_x=value
		var tex=resources.get_number_texture(value)
		$Cube.x_face.set_shader_param("tex_number",tex)

func set_mode_x(value):
	if has_node("Cube"):
		mode_x=value
		$Cube.x_face.set_shader_param("mode",value)

func set_number_y(value):
	if has_node("Cube"):
		number_y=value
		var tex=resources.get_number_texture(value)
		$Cube.y_face.set_shader_param("tex_number",tex)

func set_mode_y(value):
	if has_node("Cube"):
		mode_y=value
		$Cube.y_face.set_shader_param("mode",value)

func set_number_z(value):
	if has_node("Cube"):
		number_z=value
		var tex=resources.get_number_texture(value)
		$Cube.z_face.set_shader_param("tex_number",tex)

func set_mode_z(value):
	if has_node("Cube"):
		mode_z=value
		$Cube.z_face.set_shader_param("mode",value)

func set_color(value):
	if has_node("Cube"):
		color=value
		$Cube.x_face.set_shader_param("color",value)
		$Cube.y_face.set_shader_param("color",value)
		$Cube.z_face.set_shader_param("color",value)

func set_marked_color(value):
	if has_node("Cube"):
		marked_color=value
		$Cube.x_face.set_shader_param("marked_color",value)
		$Cube.y_face.set_shader_param("marked_color",value)
		$Cube.z_face.set_shader_param("marked_color",value)

func set_marked(value):
	if has_node("Cube"): 
		marked=value
		$Cube.x_face.set_shader_param("marked",value)
		$Cube.y_face.set_shader_param("marked",value)
		$Cube.z_face.set_shader_param("marked",value)

func set_found_x(value):
	if has_node("Cube"): 
		found_x=value
		$Cube.x_face.set_shader_param("found",value)

func set_found_y(value):
	if has_node("Cube"): 
		found_y=value
		$Cube.y_face.set_shader_param("found",value)

func set_found_z(value):
	if has_node("Cube"): 
		found_z=value
		$Cube.z_face.set_shader_param("found",value)

func set_reveal(value):
	if has_node("Cube"):
		reveal=value
		$Cube.x_face.set_shader_param("reveal",value)
		$Cube.y_face.set_shader_param("reveal",value)
		$Cube.z_face.set_shader_param("reveal",value)

func set_revealed_color(value):
	if has_node("Cube"):
		revealed_color=value
		$Cube.x_face.set_shader_param("revealed_color",value)
		$Cube.y_face.set_shader_param("revealed_color",value)
		$Cube.z_face.set_shader_param("revealed_color",value)

func set_hint_visible_x(value):
	if has_node("Cube"):
		hint_visible_x=value
		$Cube.x_face.set_shader_param("hint_visible",value)

func set_hint_visible_y(value):
	if has_node("Cube"):
		hint_visible_y=value
		$Cube.y_face.set_shader_param("hint_visible",value)

func set_hint_visible_z(value):
	if has_node("Cube"):
		hint_visible_z=value
		$Cube.z_face.set_shader_param("hint_visible",value)


func destroy():
	$Cube/AnimationPlayer.play("default")
	yield($Cube/AnimationPlayer, "animation_finished")	
	self.queue_free()

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if dead or not (game_data.game_status==game_data.PLAYING or game_data.game_status==game_data.HINT_EDITION):
		return
	if event is InputEventMouseButton and event.button_index==BUTTON_LEFT and event.is_pressed():
		if game_data.touch_mode==game_data.TOUCH_DESTROY:
			if marked:
				emit_signal("cell_resisted",self)
			else:
				if solid:
					broken=true
					set_marked(1)
					emit_signal("cell_destroyed",self,true)
				else:
					dead=true
					get_tree().call_group("sfx","play","break")
					emit_signal("cell_destroyed",self,false)
					destroy()
		elif game_data.touch_mode==game_data.TOUCH_PAINT and !broken: # and !(found_x or found_y or found_z):
			get_tree().call_group("sfx","play","hint")
			set_marked((marked+1)%3)
			emit_signal("cell_marked",self.translation)
		elif game_data.touch_mode==game_data.TOUCH_HINT:
			var v=click_normal.snapped(1)*2+translation
			var axis=0
			if abs(click_normal.y)>0.5:
				axis=1
			elif abs(click_normal.z)>0.5:
				axis=2
			
			emit_signal("cell_hint_toggled",self,axis)