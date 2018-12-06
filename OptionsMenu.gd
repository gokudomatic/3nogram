extends Control

var connected_tex=preload("res://textures/connected.png")
var disconnected_tex=preload("res://textures/disconnected.png")
var configs=[]

func _ready():
	get_tree().call_group("sfx","set_music","menu.ogg")
	fill_servers()
	$TabContainer/Audio/SfxSlider/MuteCheckBox.pressed=game_data.config.nosound
	$TabContainer/Audio/MusicSlider/MuteCheckBox.pressed=game_data.config.nomusic
	$TabContainer/Audio/SfxSlider.value=game_data.config.sound_volume
	$TabContainer/Audio/MusicSlider.value=game_data.config.music_volume

func fill_servers():
	for server_name in game_data.config.servers.keys():
		var cfg=game_data.config.servers[server_name]
		configs.append(cfg)
		if cfg.auth_token!='':
			$TabContainer/Servers/Control/server_list.add_item(server_name+" - "+cfg.username,connected_tex)
		else:
			$TabContainer/Servers/Control/server_list.add_item(server_name,disconnected_tex)


func _on_BackBtn_pressed():
	get_tree().call_group("sfx","stop","intro")
	get_tree().call_group("sfx","play","select")
	get_tree().change_scene("res://MainMenu.tscn")


func _on_server_list_item_selected(index):
	var cfg=configs[index]
	$LoginDialog.set_server_cfg(cfg)
	update_connect_btn(cfg.auth_token!='')
	
func update_connect_btn(is_connected):
	if is_connected:
		$TabContainer/Servers/Control/ConnectBtn.text="Disconnect"
		$TabContainer/Servers/Control/ConnectBtn.icon=disconnected_tex
	else:
		$TabContainer/Servers/Control/ConnectBtn.text="Connect"
		$TabContainer/Servers/Control/ConnectBtn.icon=connected_tex

func _on_ConnectBtn_pressed():
	var server_list=$TabContainer/Servers/Control/server_list
	if server_list.get_selected_items().size()==0:
		return
	var index=server_list.get_selected_items()[0]
	var cfg=configs[index]
	if cfg.auth_token=='':
		$LoginDialog.request_login()
		var result=yield($LoginDialog,"completed")
		if not result:
			return
	else:
		cfg.auth_token=''
		cfg.username=''
		game_data.save_to_file()
	update_connect_btn(cfg.auth_token!='')
	if cfg.auth_token!='':
		server_list.set_item_text(index,cfg.name+" - "+cfg.username)
		server_list.set_item_icon(index,connected_tex)
	else:
		server_list.set_item_text(index,cfg.name)
		server_list.set_item_icon(index,disconnected_tex)


func _on_SfxMuteCheckBox_toggled(button_pressed):
	game_data.config.nosound=button_pressed
	AudioServer.set_bus_mute(1,button_pressed)
	get_tree().call_group("sfx","play","select")
	game_data.save_to_file()

func _on_MusicMuteCheckBox_toggled(button_pressed):
	game_data.config.nomusic=button_pressed
	AudioServer.set_bus_mute(2,button_pressed)
	get_tree().call_group("sfx","play","select")
	game_data.save_to_file()

func _on_SfxSlider_value_changed(value):
	game_data.config.sound_volume=value
	AudioServer.set_bus_volume_db(1,value)
	get_tree().call_group("sfx","play","select")
	game_data.save_to_file()

func _on_MusicSlider_value_changed(value):
	game_data.config.music_volume=value
	AudioServer.set_bus_volume_db(2,value)
	get_tree().call_group("sfx","play","select")
	game_data.save_to_file()