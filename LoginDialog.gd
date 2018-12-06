extends PopupDialog

var sessionid=null
var server_cfg=null setget set_server_cfg
signal completed(success)

func _ready():
	pass

func set_server_cfg(value):
	assert(value!=null)
	server_cfg=value
	$RESTRequest.server_config=value
	$Server_caption.text=server_cfg.name

func request_login():
	if server_cfg.auth_token!='' and server_cfg.auth_token!=null:
		return
	server_cfg.auth_token=null
	popup_centered()
	$RESTRequest.login()
	sessionid=yield($RESTRequest,"login_completed")

func _on_tokenBtn_pressed():
	assert(sessionid!=null)
	$RESTRequest.get_token(sessionid)
	var token=yield($RESTRequest,"token_completed")
	if token==null:
		print("error during retrieving token")
		self.hide()
		emit_signal("completed",false)
	else:
		server_cfg.auth_token=token[0]
		server_cfg.username=token[1]
		game_data.save_to_file()
		print("token="+str(server_cfg.auth_token))
		print("username="+token[1])
		self.hide()
		emit_signal("completed",true)

func _on_cancelBtn_pressed():
	self.hide()
	emit_signal("completed",false)
