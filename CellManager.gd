extends Spatial

var cell_class=preload("res://BuilderCell.tscn")

var data=[]
var last_dimensions=Vector3(0,0,0)
var last_min=Vector3(0,0,0)
var last_max=Vector3(0,0,0)

func _ready():
	pass

func add_cell(position,color=null):
	var instance=cell_class.instance()
	instance.translation=position*2
	instance.connect("cell_destroyed",self,"_on_cell_cell_destroyed")
	instance.connect("cell_created",self,"_on_cell_cell_created")
	$Cells.add_child(instance)
	if color==null:
		instance.set_color(game_data.build_color)
	else:
		instance.set_color(color)
	data.append({"position":position,
		"instance":instance})

func get_dimensions():
	var border_min=Vector3(0,0,0)
	var border_max=Vector3(0,0,0)
	for d in data:
		border_min.x=min(border_min.x,d.position.x)
		border_max.x=max(border_max.x,d.position.x)
		border_min.y=min(border_min.y,d.position.y)
		border_max.y=max(border_max.y,d.position.y)
		border_min.z=min(border_min.z,d.position.z)
		border_max.z=max(border_max.z,d.position.z)
	
	return [border_min,border_max]

func recenter():
	var borders=get_dimensions()
	
	last_min=borders[0]
	last_max=borders[1]
	last_dimensions=last_max-last_min
	$Cells.translation=-2*(last_dimensions/2+last_min)

func _on_cell_cell_created(position,axis):
	var data_pos=position/2
	if last_dimensions.x>=8 and axis==0 or last_dimensions.y>=8 and axis==1 or last_dimensions.z>=8 and axis==2:
		if axis==0 and data_pos.x<last_min.x or data_pos.x>last_max.x:
			return
		elif axis==1 and data_pos.y<last_min.y or data_pos.y>last_max.y:
			return
		elif axis==2 and data_pos.z<last_min.z or data_pos.z>last_max.z:
			return
	add_cell(position/2)
	recenter()

func _on_cell_cell_destroyed(source):
	if data.size()>1:
		for d in data:
			if d.position==source.translation/2:
				data.erase(d)
				break
		source.destroy()
		recenter()

func get_data():
	var result=[]
	var min_pos=Vector3(999,999,999)
	for d in data:
		min_pos.x=min(min_pos.x,d.position.x)
		min_pos.y=min(min_pos.y,d.position.y)
		min_pos.z=min(min_pos.z,d.position.z)
	
	for d in data:
		result.append([d.position-min_pos,d.instance.color])
	
	return result