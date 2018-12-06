extends Control

var connected_tex=preload("res://textures/connected.png")
var disconnected_tex=preload("res://textures/disconnected.png")

var current_importer=null

func _ready():
	for server_name in game_data.config.servers.keys():
		if game_data.config.servers[server_name].auth_token!='':
			$server_list.add_item(server_name,connected_tex)
		else:
			$server_list.add_item(server_name,disconnected_tex)

func _on_importBtn_pressed():
	if current_importer==null:
		return
	
	current_importer.execute_import()

func _on_backBtn_pressed():
	get_tree().change_scene("res://LevelSelection.tscn")

func _on_server_list_item_selected(index):
	$importBtn.disabled=true
	if index>0:
		var server_name=$server_list.get_item_text(index)
		$RestImportPanel.show()
		current_importer=$RestImportPanel
		$RestImportPanel.server_config=game_data.config.servers[server_name]
		$RestImportPanel.clear_search()
	elif index==0:
		$RestImportPanel.hide()
		current_importer=null

func _on_busy_status_changed(is_busy):
	if is_busy:
		$loading_screen.show()
	else:
		$loading_screen.hide()


func _on_RestImportPanel_puzzle_selected(is_any):
	$importBtn.disabled=not is_any


func _on_RestImportPanel_logged_in():
	var idx=$server_list.get_selected_items()[0]
	if idx>0:
		$server_list.set_item_icon(idx,connected_tex)
