extends Control

var login_dialog_class=preload("res://LoginDialog.tscn")

var connected_tex=preload("res://textures/connected.png")
var disconnected_tex=preload("res://textures/disconnected.png")

var login_dialog=null

var quality=0 setget set_quality

func _ready():
	fill_server_list()
	load_evaluation()

func fill_server_list():
	for server_name in game_data.config.servers.keys():
		if game_data.config.servers[server_name].auth_token!='':
			$Panel/ServerList.add_item(server_name,connected_tex)
		else:
			$Panel/ServerList.add_item(server_name,disconnected_tex)

func load_evaluation():
	var evaluation=game_data.current_puzzle.my_rank
	set_quality(evaluation.vote)
	$Panel/CheckBox/StarBtn.pressed=evaluation.family_friendly

func _on_StarBtn2_pressed():
	set_quality(2)

func _on_StarBtn3_pressed():
	set_quality(3)

func _on_StarBtn4_pressed():
	set_quality(4)

func _on_StarBtn5_pressed():
	set_quality(5)

func set_quality(value):
	quality=value
	if has_node("Panel/HBoxContainer"):
		$Panel/HBoxContainer/StarBtn1.pressed=value>=1
		$Panel/HBoxContainer/StarBtn2.pressed=value>=2
		$Panel/HBoxContainer/StarBtn3.pressed=value>=3
		$Panel/HBoxContainer/StarBtn4.pressed=value>=4
		$Panel/HBoxContainer/StarBtn5.pressed=value>=5

func _on_StarBtn1_toggled(button_pressed):
	if button_pressed:
		set_quality(1)
	else:
		set_quality(0)

func _on_VoteBtn_pressed():
	
	var puzzle=game_data.current_puzzle
	var ranks=puzzle.ranks
	if puzzle.my_rank.completed:
		var last_vote=puzzle.my_rank.vote
		ranks.quality[last_vote]=max(0,ranks.quality[last_vote]-1)
		if last_vote.family_friendly:
			ranks.family_friendly-=1
	else:
		ranks.vote_count+=1
	
	ranks.quality[quality]+=1
	if $Panel/CheckBox/StarBtn.pressed:
		ranks.family_friendly+=1
	puzzle.my_rank.vote=quality
	puzzle.my_rank.family_friendly=$Panel/CheckBox/StarBtn.pressed

	$loading_screen.show()
	for server_idx in $Panel/ServerList.get_selected_items():
		$RESTRequest.server_config=game_data.config.servers[$Panel/ServerList.get_item_text(server_idx)]
		$RESTRequest.vote_puzzle(puzzle)
		yield($RESTRequest,"vote_completed")
	$loading_screen.hide()
	
	game_data.save_to_file()
	
	get_tree().change_scene("res://MainMenu.tscn")


func _on_LoginBtn_pressed():
	var login_dlg=login_dialog_class.instance()
	add_child(login_dlg)
	
	for server_idx in $Panel/ServerList.get_selected_items():
		var server_cfg=game_data.config.servers[$Panel/ServerList.get_item_text(server_idx)]
		if server_cfg.auth_token=='':
			login_dlg.server_cfg=server_cfg
			
			login_dlg.request_login()
			if not yield(login_dlg,"completed"):
				break
			else:
				$Panel/ServerList.set_item_icon(server_idx,connected_tex)
	
	remove_child(login_dlg)