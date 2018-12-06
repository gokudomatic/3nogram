extends Control

var login_dialog=null
var sessionid=null
var filter=null
var server_cfg setget set_server_cfg

func _ready():
	pass

func set_server_cfg(value):
	server_cfg=value
	$RESTRequest.server_config=value
	if $LoginPanel!=null:
		$LoginPanel/ServerCaptionLabel.text=value.name

func fill_tab(filter):
	if server_cfg.auth_token==null:
		$ExportPanel.hide()
		$LoginPanel.show()
		return
	else:
		$ExportPanel.show()
		$LoginPanel.hide()
	self.filter=filter
	var tree=$ExportPanel/SummaryTree
	tree.clear()
	tree.columns=1
	var root=tree.create_item()
	var puzzles=game_data.get_my_puzzles(filter)
	for puzzle in puzzles:
		var line = tree.create_item(root)
		line.set_text(0,puzzle.name)

func _on_SendBtn_pressed(): 
	var puzzles=game_data.get_my_puzzles(self.filter)
	
	$RESTRequest.send(puzzles)
	var success=yield($RESTRequest,"send_completed")
	if success:
		$ExportPanel/StatusLabel.text="OK"
		game_data.save_to_file()
	else:
		$ExportPanel/StatusLabel.text="Failed"

func get_tree():
	return $ExportPanel/SummaryTree

func _on_LoginBtn_pressed():
	$RESTRequest.login()
	sessionid=yield($RESTRequest,"login_completed")
	$LoginPanel/TokenBtn.disabled=false

func _on_TokenBtn_pressed():
	assert(sessionid!=null)
	$RESTRequest.get_token(sessionid)
	var rest_token=yield($RESTRequest,"token_completed")
	if rest_token!=null:
		server_cfg.auth_token=rest_token[0]
		server_cfg.username=rest_token[1]
		game_data.save_to_file()
		$LoginPanel.hide()
		$ExportPanel.show()
	else:
		print("couldn't get token")