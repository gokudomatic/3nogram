extends HTTPRequest

var server_config=null

var api_prefix="/api/backend/"
var scenetree=null
var ssl_mode=false

signal rest_completed(body)
signal import_completed(result)
signal login_completed(sessionid)
signal token_completed(token)
signal send_completed(result)
signal vote_completed(result)
signal search_completed(result)

func _ready():
	pass

func _on_RESTRequest_request_completed(result, response_code, headers, body):
	print(body.get_string_from_utf8())
	var json = JSON.parse(body.get_string_from_utf8())
	self.emit_signal("rest_completed",json.result)
	
func request_version():
	self.request(server_config.url+api_prefix+"version/")

func request_user_list():
	self.request(server_config.url+api_prefix+"users/")

func request_puzzles(userid):
	self.request(server_config.url+api_prefix+"collection/"+str(userid)+"/")

func search(parameters):
	# prepare url for parameters
	var get_params=[]
	
	if parameters.has("id") and not parameters["id"].empty():
		get_params=["puzzle_id="+parameters["id"]]
	else:
		if parameters.has("family_friendly") and parameters["family_friendly"]==true:
			get_params.append("family_friendly=true")
		if parameters.has("tags") and not parameters["tags"].empty():
			get_params.append("tag="+parameters["tags"].percent_encode())
		if parameters.has("quality") and parameters["quality"]>0:
			get_params.append("quality="+str(parameters["quality"]))
		if parameters.has("sort") and parameters["sort"]!="default":
			get_params.append("sort_type="+parameters["sort"])
		if parameters.has("new_only") and parameters["new_only"]==true:
			get_params.append("new_only=true")
	
	var str_get_params=""
	for param in get_params:
		if not str_get_params.empty():
			str_get_params+="&"
		str_get_params+=param
	if not str_get_params.empty():
			str_get_params="?"+str_get_params
	self.request(server_config.url+api_prefix+"search/puzzles"+str_get_params,get_rest_headers())
	var result=yield(self,"rest_completed")
	emit_signal("search_completed",result)

func import(ids):
	var str_ids=str(ids[0])
	for i in range(1,ids.size()):
		str_ids+=","+str(ids[i])
	self.request(server_config.url+api_prefix+"puzzles?ids="+str_ids)
	var result=yield(self,"rest_completed")
	
	for puzzle_json in result:
		var puzzle=game_data.get_puzzle_by_id(puzzle_json.id)
		if puzzle==null:
			if puzzle_json.author==server_config.username:
				puzzle=game_data.create_puzzle_generic(null)
			else:
				puzzle=game_data.create_puzzle_generic(puzzle_json.author)
		puzzle.name=puzzle_json.name
		var dimensions=JSON.parse(puzzle_json.dimensions).result
		puzzle.dimensions=puzzle.toVector3(dimensions)
		var data=JSON.parse(puzzle_json.data).result
		
		var check_dups_map={}
		puzzle.data=[]
		for line in data:
			var cell=puzzle.toVector3(line[0])
			var dup_key=str(cell.x)+","+str(cell.y)+","+str(cell.z)
			if not  check_dups_map.has(dup_key):
				check_dups_map[dup_key]=true
				if line.size()>1:
					puzzle.data.append([cell,Color(line[1])])
				else:
					puzzle.data.append([cell,Color(1,1,1)])

		puzzle.id=puzzle_json.id
		puzzle.warning_time_limit=puzzle_json.warning_time_limit
		puzzle.gameover_time_limit=puzzle_json.gameover_time_limit
		puzzle.lifes=puzzle_json.lifes
		puzzle.hints=JSON.parse(puzzle_json.hints).result
		
	game_data.save_to_file()
	emit_signal("import_completed",result)


func login():
	self.request(server_config.url+api_prefix+"session/create")
	var session_json=yield(self,"rest_completed")
	var sessionid=session_json.sessionid
	
	print("sessionid: ",sessionid)
	var request_full_url=server_config.url+api_prefix+"signin/?sessionid="+str(sessionid)
	print("request: ",request_full_url)
	OS.shell_open(request_full_url)
	emit_signal("login_completed",sessionid)

func get_token(sessionid):
	self.request(server_config.url+api_prefix+"token/?sessionid="+str(sessionid))
	var token_json=yield(self,"rest_completed")
	if token_json!=null:
		emit_signal("token_completed",[token_json.token,token_json.username])
	else:
		emit_signal("token_completed",null)

func get_rest_headers():
	if server_config.auth_token != '':
		return ["Content-Type: application/json","Authorization: Token "+server_config.auth_token]
	else:
		return ["Content-Type: application/json"]

func send(puzzles):
	if server_config.auth_token=='':
		emit_signal("send_completed",false)
		return
	
	var success=true
	for puzzle in puzzles:

		var pk_puzzle=puzzle.id
		var json_body=serialize(puzzle)
		var response
		if str(pk_puzzle).length()<30:
			request(server_config.url+api_prefix+"puzzle/",get_rest_headers(),ssl_mode,HTTPClient.METHOD_POST,json_body)
			response=yield(self,"rest_completed")
		else:
			request(server_config.url+api_prefix+"puzzle/%s/" % [pk_puzzle],get_rest_headers(),ssl_mode,HTTPClient.METHOD_PUT,json_body)
			response=yield(self,"rest_completed")
		if response==null:
			print("No answer")
			success=false
		elif response.has("status_code") and str(response.status_code)!="200":
			print(response)
			success=false
		elif response.has("id"):
			puzzle.id=response.id
			
	emit_signal("send_completed",success)

func serialize(puzzle):
	var data=puzzle.write_to_json()
	data.erase("id")
	data.dimensions=JSON.print(data.dimensions)
	data.data=JSON.print(data.data)
	data.hints=JSON.print(data.hints)
	data["warning_time_limit"]=data.time[0]
	data["gameover_time_limit"]=data.time[1]
	data.erase("time")
	var json=JSON.print(data)
	return json

func vote_puzzle(puzzle):
	if server_config.auth_token=='':
		emit_signal("vote_completed",false)
		return
	
	var json_body=JSON.print({"puzzle_id":puzzle.id,"quality":puzzle.my_rank.vote,"family_friendly":puzzle.my_rank.family_friendly})
	print(json_body)
	request(server_config.url+api_prefix+"rank/vote/",get_rest_headers(),ssl_mode,HTTPClient.METHOD_POST,json_body)
	var response=yield(self,"rest_completed")
	if response.has("result") and response.result=="ok":
		print("ok")
		emit_signal("vote_completed",true)
	else:
		print("NOK")
		emit_signal("vote_completed",false)

