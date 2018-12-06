extends Node

var hostname="http://gokudomatic.pythonanywhere.com"
var api_prefix="/api/backend/"
var scenetree=null

func _ready():
	pass

func get_version():
	$HTTPRequest.request(hostname+api_prefix+"version/")
	print("get_version")
	var result=justrest.it(hostname+api_prefix+"version/",scenetree)
	if result==null:
		result=justrest.it(hostname+api_prefix+"version/",scenetree)
	if result==null:
		return null
	else:
		return result.version

func get_user_list():
	return justrest.it(hostname+api_prefix+"users/")

func get_puzzles(userid):
	return justrest.it(hostname+api_prefix+"collection/"+str(userid)+"/")

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
	
	var str_get_params=""
	for param in get_params:
		if not str_get_params.empty():
			str_get_params+="&"
		str_get_params+=param
	if not str_get_params.empty():
			str_get_params="?"+str_get_params
	return justrest.it(hostname+api_prefix+"search/puzzles"+str_get_params)

func import(ids):
	var str_ids=str(ids[0])
	for i in range(1,ids.size()):
		str_ids+=","+str(ids[i])
	var result=justrest.it(hostname+api_prefix+"puzzles?ids="+str_ids)
	
	for puzzle_json in result:
		var puzzle=game_data.get_puzzle_by_id(puzzle_json.id)
		if puzzle!=null:
			puzzle=game_data.create_puzzle_generic(puzzle_json.author)
		puzzle.name=puzzle_json.name
		var dimensions=JSON.parse(puzzle_json.dimensions).result
		puzzle.dimensions=puzzle.toVector3(dimensions)
		var data=JSON.parse(puzzle_json.data).result
		for line in data:
			if line.size()>1:
				puzzle.data.append([puzzle.toVector3(line[0]),Color(line[1])])
			else:
				puzzle.data.append([puzzle.toVector3(line[0]),Color(1,1,1)])

		puzzle.id=puzzle_json.id
		puzzle.warning_time_limit=puzzle_json.warning_time_limit
		puzzle.gameover_time_limit=puzzle_json.gameover_time_limit
		puzzle.lifes=puzzle_json.lifes
		puzzle.hints=JSON.parse(puzzle_json.hints).result
		
	return result


func login():
	var session_json=justrest.it(hostname+api_prefix+"session/create")
	var sessionid=session_json.sessionid
	
	OS.shell_open(hostname+api_prefix+"signin/?sessionid="+str(sessionid))
	return sessionid

func get_token(sessionid):
	var token_json=justrest.it(hostname+api_prefix+"token/?sessionid="+str(sessionid))
	if token_json!=null:
		return [token_json.token,token_json.username]
	else:
		return null

func send(puzzles):
	var success=true
	var connection=justrest.open(hostname).json_type().tokenauth(game_data.config.auth_token)
	for puzzle in puzzles:

		var pk_puzzle=puzzle.id
		var json_body=serialize(puzzle)
		connection.body(json_body)
		var response
		if pk_puzzle.length()<30:
			response=connection.post(api_prefix+"puzzle/")
		else:
			response=connection.put("%spuzzle/%s/" % [api_prefix,pk_puzzle])
		if response==null:
			print("No answer")
			success=false
		elif response.has("status_code") and str(response.status_code)!="200":
			print(response)
			success=false
		elif response.has("id"):
			puzzle.id=response.id
			
	connection.close()
	return success

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
	var connection=justrest.open(hostname).json_type().tokenauth(game_data.config.auth_token)
	var json_body=JSON.print({"puzzle_id":puzzle.id,"quality":puzzle.my_rank.vote,"family_friendly":puzzle.my_rank.family_friendly})
	connection.body(json_body)
	print(json_body)
	var response=connection.post(api_prefix+"rank/vote/")
	if response.has("result") and response.result=="ok":
		print("ok")
		return true
	else:
		print("NOK")
		return false