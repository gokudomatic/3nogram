extends Panel

const fields = ['','id','Author','Quality','Fam.','Tags','Level','Time','Lifes']
const field_sizes = [20,45,-1,60,45,-1,45,50,45]

var server_config=null setget set_server_config

signal import_completed
signal busy_status_changed(is_busy)

signal logged_in
signal puzzle_selected(is_any)


func _ready():
	pass

func clear_search():
	emit_signal("busy_status_changed",true)
	$RESTRequest.search({})

func set_server_config(value):
	server_config=value
	$RESTRequest.server_config=value
	$LoginDialog.server_cfg=value
	if value!=null and value.auth_token!='':
		$only_new_btn.show()
		$login_btn.hide()
	else:
		$only_new_btn.hide()
		$login_btn.show()
		

func execute_import():
	var id_list=[]
	var item=$resultGrid.get_root().get_children()
	while item!=null:
		if item.is_checked(0):
			id_list.append(item.get_text(1).right(1))
		item=item.get_next()

	emit_signal("busy_status_changed",true)
	$RESTRequest.import(id_list)
	var data=yield($RESTRequest,"import_completed")
	print(data)
	emit_signal("import_completed")
	emit_signal("busy_status_changed",false)

func _on_searchBtn_pressed():
	var params={
		"family_friendly":$fam_friendly_btn.pressed,
		"new_only":$only_new_btn.pressed,
		"tags":$tagEdit.text,
		"quality":$qualityCombo.get_selected_id(),
		"sort":$sortCombo.get_item_text($sortCombo.get_selected_id()).to_lower()
	}
	
	emit_signal("busy_status_changed",true)
	$RESTRequest.search(params)

func _on_login_btn_pressed():
	$LoginDialog.request_login()
	if yield($LoginDialog,"completed"):
		$login_btn.hide()
		$only_new_btn.show()
		emit_signal("logged_in")

func _on_search_completed(data):
	var grid=$resultGrid
	grid.clear()
	grid.columns=fields.size()
	for i in range(grid.columns):
		grid.set_column_title(i,fields[i])
		if field_sizes[i]!=-1:
			grid.set_column_expand(i,false)
			grid.set_column_min_width(i,field_sizes[i])
	grid.set_column_titles_visible(true)
	
	var root=grid.create_item()
	
	for entry in data:
		var fam_friendly="N"
		if entry.family_friendly:
			fam_friendly="Y"
		var quality=""
		for i in range(entry.quality):
			quality+="*"
		
		var line = grid.create_item(root)
		var i=0
		line.set_cell_mode(i,TreeItem.CELL_MODE_CHECK); line.set_editable(i,true); i+=1
		line.set_text(i,"#"+str(entry.id)); line.set_text_align(i,TreeItem.ALIGN_RIGHT); i+=1
		line.set_text(i,entry.author); i+=1
		line.set_text(i,quality); line.set_text_align(i,TreeItem.ALIGN_CENTER); i+=1
		line.set_text(i,fam_friendly); line.set_text_align(i,TreeItem.ALIGN_CENTER); i+=1
		line.set_text(i,entry.tags); i+=1
		line.set_text(i,str(entry.difficulty)); line.set_text_align(i,TreeItem.ALIGN_CENTER); i+=1
		line.set_text(i,str(entry.warning_time_limit)+" / "+str(entry.gameover_time_limit)); i+=1
		line.set_text(i,str(entry.lifes)); line.set_text_align(i,TreeItem.ALIGN_CENTER); i+=1
	emit_signal("busy_status_changed",false)

func _on_resultGrid_item_edited():
	var item=$resultGrid.get_root().get_children()
	var any_puzzle_selected=false
	while item!=null:
		if item.is_checked(0):
			print("selected")
			any_puzzle_selected=true
			break
		item=item.get_next()
	emit_signal("puzzle_selected",any_puzzle_selected)

