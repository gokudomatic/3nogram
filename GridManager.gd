extends Spatial

var hints=[]

var invisible_cells=[]

var visible_hints
export(Array, Vector3) var data
export(Vector3) var size=Vector3()
export(bool) var generate=false setget set_generate

export(int) var cut_position_x=-1 setget set_cut_position_x
export(int) var cut_position_z=-1 setget set_cut_position_z
export(int) var cut_direction_x=0
export(int) var cut_direction_z=0

signal mistaked
signal finished
signal hint_toggled(axis,position)

var cell_class=load("res://Cell.tscn")

func _ready():
	$handlers/x_handler.color=Color(1,0,0,1)
	$handlers/z_handler.color=Color(0,0,1,1)

func set_data(data):
	self.data=data

func set_generate(value): 
	if !has_node("Cells"):
		return
	
	generate=value
	if(generate):
		build_hints()
		build_grid()
	else:
		while $Cells.get_child_count()>0:
			var child=$Cells.get_children()[0]
			$Cells.remove_child(child)
			child.queue_free()

func build_grid():
	
	while $Cells.get_child_count()>0:
		var child=$Cells.get_children()[0]
		$Cells.remove_child(child)
		child.queue_free()
	
	cut_direction_x=0
	cut_direction_z=0
	
	var instances=[]
	
	var offset=size-Vector3(1,1,1)
	
	$Cells.translation=-offset
	$handlers.translation=-offset-Vector3(1,1,1)
	
	for i in range(size.x):
		for j in range(size.y):
			for h in range(size.z):
				var cell=cell_class.instance()
				cell.set_translation(Vector3(i*2,j*2,h*2))
				$Cells.add_child(cell)
				
				cell.number_x=min(9,hints[0][h][j][0])
				cell.mode_x=max(0,min(2,hints[0][h][j][1]-1)) # convert group count to mode : 0,1=0 ; 2=1 ; 3..n=2
				cell.hint_visible_x=is_hint_visible(0,h,j)

				cell.number_y=min(9,hints[1][i][h][0])
				cell.mode_y=max(0,min(2,hints[1][i][h][1]-1)) # convert group count to mode : 0,1=0 ; 2=1 ; 3..n=2
				cell.hint_visible_y=is_hint_visible(1,i,h)

				cell.number_z=min(9,hints[2][i][j][0])
				cell.mode_z=max(0,min(2,hints[2][i][j][1]-1)) # convert group count to mode : 0,1=0 ; 2=1 ; 3..n=2
				cell.hint_visible_z=is_hint_visible(2,i,j)
				for d in data:
					if d[0].x==i and d[0].y==j and d[0].z==h:
						cell.solid=true
						cell.revealed_color=d[1]
						break
				
				cell.connect("cell_marked",self,"on_cell_marked")
				if game_data.game_status==game_data.PLAYING:
					cell.connect("cell_destroyed",self,"on_cell_destroyed")
				cell.connect("cell_hint_toggled",self,"on_cell_hint_toggled")
				instances.append(cell)
	reset_handlers()
	update_handler_positions(get_viewport().get_camera().global_transform)

func is_hint_visible(axis,i,j):
	for face in visible_hints[axis]:
		if face[0]==i and face[1]==j:
			return true
	
	return false

func on_cell_destroyed(source,is_mistake):
	on_cell_marked(source.translation)
	if is_mistake:
		emit_signal("mistaked")
	else:
		var cnt=0
		for child in $Cells.get_children():
			if not child.dead:
				cnt+=1
		if cnt==data.size():
			reset_handlers()
			$handlers.hide()
			for child in $Cells.get_children():
				child.reveal=true
			emit_signal("finished")

func on_cell_hint_toggled(source,axis):
	if game_data.game_status==game_data.HINT_EDITION:
		var trans=source.translation/2
		var pos=[trans.z,trans.y]
		if axis==1:
			pos=[trans.x,trans.z]
		elif axis==2:
			pos=[trans.x,trans.y]
		
		var found=false
		for hint in visible_hints[axis]:
			if hint==pos:
				found=true
		
		if found:
			# remove
			visible_hints[axis].erase(pos)
		else:
			# add
			visible_hints[axis].append(pos)
		
		if axis==0:
			for child in $Cells.get_children():
				if child.translation.y==source.translation.y and child.translation.z==source.translation.z:
					child.hint_visible_x=!found
			for child in invisible_cells:
				if child.translation.y==source.translation.y and child.translation.z==source.translation.z:
					child.hint_visible_x=!found
		elif axis==1:
			for child in $Cells.get_children():
				if child.translation.x==source.translation.x and child.translation.z==source.translation.z:
					child.hint_visible_y=!found
			for child in invisible_cells:
				if child.translation.x==source.translation.x and child.translation.z==source.translation.z:
					child.hint_visible_y=!found
		elif axis==2:
			for child in $Cells.get_children():
				if child.translation.x==source.translation.x and child.translation.y==source.translation.y:
					child.hint_visible_z=!found
			for child in invisible_cells:
				if child.translation.x==source.translation.x and child.translation.y==source.translation.y:
					child.hint_visible_z=!found
		
		emit_signal("hint_toggled",axis,pos)

func on_cell_marked(pos):
	var x=pos.x
	var y=pos.y
	var z=pos.z
	
	var count=Vector3(0,0,0)
	var count_marked=Vector3(0,0,0)
	var x_row=[]
	var y_row=[]
	var z_row=[]
	for child in $Cells.get_children():
		if child.dead:
			continue
		if child.translation.y==y && child.translation.z==z:
			count.x+=1
			if child.marked:
				count_marked.x+=1
				x_row.append(child)
		if child.translation.x==x && child.translation.z==z:
			count.y+=1
			if child.marked:
				count_marked.y+=1
				y_row.append(child)
		if child.translation.x==x && child.translation.y==y:
			count.z+=1
			if child.marked:
				count_marked.z+=1
				z_row.append(child)
	
	if count_marked.x>0 and count.x==count_marked.x and count.x==x_row[0].number_x:
		for child in x_row:
			child.found_x=true
	if count_marked.y>0 and count.y==count_marked.y and count.y==y_row[0].number_y:
		for child in y_row:
			child.found_y=true
	if count_marked.z>0 and count.z==count_marked.z and count.z==z_row[0].number_z:
		for child in z_row:
			child.found_z=true
	

func build_hints():
	var temp_array=[] # x axis
	for i in range(size.x):
		temp_array.append([]) # y axis
		for j in range(size.y):
			temp_array[i].append([]); # z axis
			for h in range(size.z):
				var value = 0
				if data!=null:
					for d in data:
						if d[0].x==i and d[0].y==j and d[0].z==h:
							value=1
							break
				temp_array[i][j].append(value)
	
	hints=[]
	for i in range(3):
		hints.append([])
	for i in range(size.x):
		hints[2].append([])
		hints[1].append([])
		for j in range(size.y):
			hints[2][i].append([0,0]) # count, group count
		for j in range(size.z):
			hints[1][i].append([0,0]) # count, group count
	for i in range(size.z):
		hints[0].append([])
		for j in range(size.y):
			hints[0][i].append([0,0]) # count, group count
	
	# add count on Z axis
	for i in range(size.x):
		for j in range(size.y):
			var group_count=0
			var was_solid=false
			for h in range(size.z): 
				var value=(temp_array[i][j][h]==1)
				if value:
					hints[2][i][j][0]+=1 
					if not was_solid:
						group_count+=1
				was_solid=value 
			hints[2][i][j][1]=group_count
	
	# add count on X axis
	for i in range(size.z):
		for j in range(size.y):
			var group_count=0
			var was_solid=false
			for h in range(size.x):
				var value=temp_array[h][j][i]==1
				if value:
					hints[0][i][j][0]+=1
					if not was_solid:
						group_count+=1
				was_solid=value
			hints[0][i][j][1]=group_count
	
	# add count on Y axis
	for i in range(size.x):
		for j in range(size.z):
			var group_count=0
			var was_solid=false
			for h in range(size.y):
				var value=temp_array[i][h][j]==1
				if value:
					hints[1][i][j][0]+=1
					if not was_solid:
						group_count+=1
				was_solid=value
			hints[1][i][j][1]=group_count

func set_cut_position_x(value):
	if !has_node("hidden_outline"):
		return
	
	cut_position_x=value
	
	if cut_direction_x==0:
		$hidden_outline.visible=false
		for child in invisible_cells:
			$Cells.add_child(child)
		invisible_cells.clear()
	else:
		var box
		if cut_direction_x<0:
			box=[size.x-(size.x-value-1)*2,size.x]
		else:
			box=[-size.x+value*2,-size.x]
		draw_box(box[0],box[1],0)
		$hidden_outline.visible=true
		
		for child in $Cells.get_children():
			if (cut_direction_x>0 and child.translation.x<value*2) or (cut_direction_x<0 and child.translation.x>value*2):
				$Cells.remove_child(child)
				invisible_cells.append(child)
		
		var idx=0
		while idx<invisible_cells.size():
			var child=invisible_cells[idx]
			var child_pos=child.translation.x
			if (cut_direction_x>0 and child_pos>=value*2) or (cut_direction_x<0 and child_pos<=value*2):
				invisible_cells.remove(idx)
				$Cells.add_child(child)
			else:
				idx+=1

func draw_box(pos0,pos1,axis):
	var points=[[-1,-1],[-1,1],[1,1],[1,-1]]
	var im=$hidden_outline
	
	im.clear()
	im.begin(Mesh.PRIMITIVE_LINE_LOOP,null)
	for point in points:
		if axis==0:
			im.add_vertex(Vector3(pos0,point[0]*size.y,point[1]*size.z))
		elif axis==1:
			im.add_vertex(Vector3(point[1]*size.x,point[0]*size.y,pos0))
	im.end()

	im.begin(Mesh.PRIMITIVE_LINE_LOOP,null)
	for point in points:
		if axis==0:
			im.add_vertex(Vector3(pos1,point[0]*size.y,point[1]*size.z))
		elif axis==1:
			im.add_vertex(Vector3(point[1]*size.x,point[0]*size.y,pos1))
	im.end()
	
	for point in points:
		im.begin(Mesh.PRIMITIVE_LINE_STRIP,null)
		if axis==0:
			im.add_vertex(Vector3(pos0,point[0]*size.y,point[1]*size.z))
			im.add_vertex(Vector3(pos1,point[0]*size.y,point[1]*size.z))
		elif axis==1:
			im.add_vertex(Vector3(point[1]*size.x,point[0]*size.y,pos0))
			im.add_vertex(Vector3(point[1]*size.x,point[0]*size.y,pos1))
		im.end()


func set_cut_position_z(value):
	if !has_node("hidden_outline"):
		return
		
	cut_position_z=value
	
	if cut_direction_z==0:
		$hidden_outline.visible=false
		for child in invisible_cells:
			$Cells.add_child(child)
		invisible_cells.clear()
	else:
		var box
		if cut_direction_z<0:
			box=[size.z-(size.z-value-1)*2,size.z]
		else:
			box=[-size.z+value*2,-size.z]
		draw_box(box[0],box[1],1)
		$hidden_outline.visible=true
		
		for child in $Cells.get_children():
			if (cut_direction_z>0 and child.translation.z<value*2) or (cut_direction_z<0 and child.translation.z>value*2):
				$Cells.remove_child(child)
				invisible_cells.append(child)
		
		var idx=0
		while idx<invisible_cells.size():
			var child=invisible_cells[idx]
			var child_pos=child.translation.z
			if (cut_direction_z>0 and child_pos>=value*2) or (cut_direction_z<0 and child_pos<=value*2):
				invisible_cells.remove(idx)
				$Cells.add_child(child)
			else:
				idx+=1

func update_handler_positions(camera_transform):
	if cut_direction_z!=0 or cut_direction_x!=0 or not (game_data.game_status==game_data.PLAYING or game_data.game_status==game_data.HINT_EDITION):
		return # if in cutting phase, don't update
	
	var offset_x=-1
	var offset_z=-1
	if camera_transform.basis.z.x>0:
		offset_x=1
	if camera_transform.basis.z.z>0:
		offset_z=1
	
	if offset_x!=offset_z:
		$handlers.transform=Transform(Vector3(0,0,-offset_x),Vector3(0,1,0),Vector3(-offset_z,0,0),Vector3(size.x*-offset_x,-size.y,size.z*-offset_z))
		$handlers/z_handler.translation=Vector3(0,0,size.x*2+1)
		$handlers/x_handler.translation=Vector3(size.z*2+1,0,0)
	else:
		$handlers.transform=Transform(Vector3(offset_x,0,0),Vector3(0,1,0),Vector3(0,0,offset_z),Vector3(size.x*-offset_x,-size.y,size.z*-offset_z))
		$handlers/z_handler.translation=Vector3(0,0,size.z*2+1)
		$handlers/x_handler.translation=Vector3(size.x*2+1,0,0)

func reset_handlers():
	if cut_direction_x==0:
		cut_position_z=0
		cut_direction_z=0
		set_cut_position_x(0)
	else:
		cut_position_x=0
		cut_direction_x=0
		set_cut_position_z(0)
	$handlers/z_handler.visible=true
	$handlers/x_handler.visible=true
	update_handler_positions(get_viewport().get_camera().global_transform)

func _on_Camera_position_changed(camera):
	update_handler_positions(camera.global_transform)

func _on_z_handler_value_changed(value):
	var handler_z_axis=$handlers.transform.basis.z
	var max_size=size.z
	var reverse_dir=handler_z_axis.z==1
	if handler_z_axis.z==0:
		max_size=size.x
		reverse_dir=handler_z_axis.x==1

	var cut_dir=0

	var new_value=min(max_size,max(1,($handlers/z_handler.translation.z-1)/2+value))
	$handlers/z_handler.translation=Vector3(0,0,new_value*2+1)
	
	if new_value!=max_size:
		if reverse_dir:
			cut_dir=-1
			new_value-=1
		else:
			cut_dir=1
			new_value=max_size-new_value
	
	$handlers/x_handler.visible=cut_dir==0
	
	if handler_z_axis.z==0:
		cut_direction_x=cut_dir
		set_cut_position_x(new_value)
	else:
		cut_direction_z=cut_dir
		set_cut_position_z(new_value)


func _on_x_handler_value_changed(value):
	var handler_x_axis=$handlers.transform.basis.x
	var max_size=size.x
	var reverse_dir=handler_x_axis.x==1
	if handler_x_axis.x==0:
		max_size=size.z
		reverse_dir=handler_x_axis.z==1

	var cut_dir=0

	var new_value=min(max_size,max(1,($handlers/x_handler.translation.x-1)/2+value))
	$handlers/x_handler.translation=Vector3(new_value*2+1,0,0)
	
	if new_value!=max_size:
		if reverse_dir:
			cut_dir=-1
			new_value-=1
		else:
			cut_dir=1
			new_value=max_size-new_value
	
	$handlers/z_handler.visible=cut_dir==0
	
	if handler_x_axis.x==0:
		cut_direction_z=cut_dir
		set_cut_position_z(new_value)
	else:
		cut_direction_x=cut_dir
		set_cut_position_x(new_value)

func reset_cells():
	var actual_children=$Cells.get_child_count()+invisible_cells.size()
	if actual_children<size.x*size.y*size.z:
		build_grid()
	else:
		reset_handlers()
		for child in $Cells.get_children():
			if !child.solid:
				child.queue_free()
		