extends Node

var attempts=5
enum {TOUCH_NORMAL, TOUCH_DESTROY, TOUCH_PAINT, TOUCH_BUILD, TOUCH_HINT}

var touch_mode=TOUCH_NORMAL

enum {PAUSE,PLAYING,GAME_OVER,MENU,HINT_EDITION}

var game_status=MENU

var is_interacting_gui=false

var puzzle_collections={}
var current_collection=null

var my_puzzles=PuzzleCollection.new()

var current_puzzle=null

var build_color=Color(1,1,1,1)

var config=null

class ServerConfig:
	var name=""
	var url=""
	var auth_token=""
	var username=""
	var connector=""
	
	func load_from_json(json):
		name=json.name
		url=json.url
		connector=json.connector
		if json.has('auth_token'):
			auth_token=json.auth_token
		if json.has('username'):
			username=json.username
	
	func write_to_json():
		return {"name":name,"url":url,"auth_token":auth_token,"username":username,"connector":connector}

class Config:
	var nosound=false
	var nomusic=false
	var sound_volume=0
	var music_volume=0
	var servers={}
	
	func load_from_json(json):
		if json.has('nosound'):
			nosound=json.nosound
		if json.has('nomusic'):
			nomusic=json.nomusic
		if json.has('sound_volume'):
			sound_volume=json.sound_volume
		if json.has('music_volume'):
			music_volume=json.music_volume

		AudioServer.set_bus_mute(1,nosound)
		AudioServer.set_bus_mute(2,nomusic)
		AudioServer.set_bus_volume_db(1,sound_volume)
		AudioServer.set_bus_volume_db(2,music_volume)
		
		if json.has('servers') and not json.servers.empty():
			for server_json in json.servers:
				var new_server=ServerConfig.new()
				new_server.load_from_json(server_json)
				servers[new_server.name]=new_server
		else:
			generate_default()
	
	func generate_default():
			var default_server=ServerConfig.new()
			default_server.name="Main Server"
			default_server.url="https://gokudomatic.pythonanywhere.com"
			default_server.connector="RESTRequest"
			servers[default_server.name]=default_server
	
	func write_to_json():
		var servers_data=[]
		for server in servers.values():
			servers_data.append(server.write_to_json())
		return {"nosound":nosound,"nomusic":nomusic,"servers":servers_data,"sound_volume":sound_volume,"music_volume":music_volume}

class MyRank:
	var completed=false
	var vote=0
	var family_friendly=false
	
	func write_to_json():
		return {"completed":completed,"vote":vote,"family_friendly":family_friendly}

class Rank:
	var quality=[0,0,0,0,0]
	var family_friendly=0
	var vote_count=0
	
	func get_median_quality():
		if vote_count==0:
			return -1

		var max_i=-1
		var max_count=-1
		for i in range(5):
			if max_count<=quality[i]:
				max_i=i
				max_count=quality[i]
		return max_i

	func get_avg_family_friendly():
		return family_friendly>vote_count*2/3
		
	func write_to_json():
		return {"quality":quality,"family_friendly":family_friendly,"vote_count":vote_count}

class Puzzle:
	var id=-1
	var is_new=true
	var name=""
	var dimensions=Vector3(0,0,0)
	var data=[]
	var lifes=5
	var hints=[[],[],[]]
	var difficulty=0
	var warning_time_limit=5
	var gameover_time_limit=15
	var ranks=null
	var my_rank=null
	
	func toVector3(collection):
		if collection.size()>=2:
			return Vector3(collection[0],collection[1],collection[2])
		else:
			return null
	
	func ofVector3(vector):
		return [vector.x,vector.y,vector.z]

	
	func load_from_json(item):
		dimensions=toVector3(item.dimensions)
		var check_dups_map={}
		data=[]
		for line in item.data:
			var cell=toVector3(line[0])
			var dup_key=str(cell.x)+","+str(cell.y)+","+str(cell.z)
			if not check_dups_map.has(dup_key):
				check_dups_map[dup_key]=true
				if line.size()>1:
					data.append([cell,Color(line[1])])
				else:
					data.append([cell,Color(1,1,1)])
		warning_time_limit=item.time[0]
		gameover_time_limit=item.time[1]
		lifes=item.lifes
		hints=item.hints
		name=item.name
		ranks=Rank.new()
		my_rank=MyRank.new()
		if item.has("id"):
			id=item.id
	
	func write_to_json():
		var json_data=[]
		for line in data:
			json_data.append([ofVector3(line[0]),line[1].to_html()])
		
		return {"id":id,"name":name,"dimensions":ofVector3(dimensions),"time":[warning_time_limit,gameover_time_limit],"lifes":lifes,
		"hints":hints,"difficulty":difficulty,"data":json_data}

class PuzzleCollection:
	var author
	var puzzles=[]
	
	func load_from_json(json):
		puzzles=[]
		for puzzle_data in json.puzzles:
			var puzzle=Puzzle.new()
			puzzle.id=puzzles.size()
			puzzle.load_from_json(puzzle_data)
			puzzles.append(puzzle)
	
	func write_to_json(filter=null):
		var puzzle_data=[]
		for puzzle in puzzles:
			if filter==null or filter.size()==0 or puzzle.name in filter:
				puzzle_data.append(puzzle.write_to_json())
		return {"puzzles":puzzle_data}

func load_from_json(json):
	if json==null:
		return
	my_puzzles=PuzzleCollection.new()
	if json.has("my_puzzles"):
		my_puzzles.load_from_json(json.my_puzzles)
	
	var collections=json.puzzles
	for author in collections:
		var json_collection=collections[author]
		var collection
		if puzzle_collections.has(author):
			collection=puzzle_collections[author]
		else:
			collection=PuzzleCollection.new()
			collection.author=author
		collection.load_from_json(json_collection)
		puzzle_collections[author]=collection

func serialize_mypuzzles(filter=null):
	return JSON.print(my_puzzles.write_to_json(filter),"    ")

func save_to_file():
	var puzzles={}
	var ranks={}
	var my_ranks={}
	for key in puzzle_collections.keys():
		puzzles[key]=puzzle_collections[key].write_to_json()
		for p in puzzle_collections[key].puzzles:
			var uid=p.id
			ranks[uid]=p.ranks.write_to_json()
			my_ranks[uid]=p.my_rank.write_to_json()
	var data={"puzzles":puzzles,"my_puzzles":my_puzzles.write_to_json()}
	var content=JSON.print(data)
	
	var file = File.new()
	file.open("user://puzzles.dat", file.WRITE)
	file.store_string(content)
	file.close()

	file.open("user://ranks.dat", file.WRITE)
	file.store_string(JSON.print({"ranks":ranks,"my_ranks":my_ranks}))
	file.close()
	
	file.open("user://config.dat", file.WRITE)
	file.store_string(JSON.print(config.write_to_json()))
	file.close()
	

func load_from_file():
	var puzzles={}
	
	var file = File.new()
	file.open("user://puzzles.dat", file.READ)
	var content = file.get_as_text()
	file.close()
	var json=JSON.parse(content).result
	load_from_json(json)
	
	for user in puzzle_collections:
		for p in puzzle_collections[user].puzzles:
			puzzles[p.id]=p
	
	file.open("user://ranks.dat", file.READ)
	content = file.get_as_text()
	file.close()
	var json_ranks=JSON.parse(content).result
	if json_ranks!=null:
		if json_ranks.has('my_ranks'):
			for id in json_ranks.my_ranks:
				var rank=json_ranks.my_ranks[id]
				var puzzle=puzzles[id]
				puzzle.my_rank=MyRank.new()
				puzzle.my_rank.completed=rank.completed
				puzzle.my_rank.vote=rank.vote
				puzzle.my_rank.family_friendly=rank.family_friendly
		for id in json_ranks.ranks:
			var rank=json_ranks.ranks[id]
			var puzzle=puzzles[id]
			puzzle.ranks=Rank.new()
			puzzle.ranks.quality=rank.quality
			puzzle.ranks.family_friendly=rank.family_friendly
			if rank.has('vote_count'):
				puzzle.ranks.vote_count=rank.vote_count
	
	config=Config.new()
	file.open("user://config.dat", file.READ)
	content = file.get_as_text()
	file.close()
	var json_config=JSON.parse(content).result
	if json_config!=null:
		config.load_from_json(json_config)
	else:
		config.generate_default()

func get_puzzle_by_id(uuid):
	for puzzle in my_puzzles.puzzles:
		if puzzle.id==uuid:
			return puzzle
	
	for coll in puzzle_collections.values():
		for puzzle in coll.puzzles:
			if puzzle.id==uuid:
				return puzzle
	return null

func create_puzzle_generic(user=null):
	var puzzle=Puzzle.new()
	puzzle.id=OS.get_unix_time()
	puzzle.name=""
	puzzle.dimensions=Vector3(1,1,1)
	puzzle.data=[[Vector3(0,0,0),Color(1,1,1,1)]]
	puzzle.id=0
	puzzle.ranks=Rank.new()
	puzzle.my_rank=MyRank.new()
	
	if user!=null:
		if not puzzle_collections.has(user):
			puzzle_collections[user]=PuzzleCollection.new()
		puzzle_collections[user].puzzles.append(puzzle)
	else:
		my_puzzles.puzzles.append(puzzle)
	
	return puzzle

func create_new_puzzle():
	current_puzzle=create_puzzle_generic()
	current_puzzle.id=my_puzzles.puzzles.size()
	current_puzzle.name="no name"
	
	return current_puzzle

func delete_mypuzzle(puzzle):
	if puzzle!=null:
		my_puzzles.puzzles.erase(puzzle)

func delete_collection(username):
	puzzle_collections.erase(username)

func _ready():
	load_from_file()

func get_my_puzzles(id_list):
	var result=[]
	var puzzles=my_puzzles.puzzles
	for puzzle_id in id_list:
		for puzzle in puzzles:
			if puzzle.name==puzzle_id:
				result.append(puzzle)
	return result
