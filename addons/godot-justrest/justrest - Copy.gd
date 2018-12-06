extends HTTPClient

signal connected()
signal connecting()
signal requesting()
signal body_received(bytes)
signal completed(data)

var uri

var _user_agent="Pirulo/1.0 (Godot)"
var _rest_headers=[]

var _request_body=""

"""
Factory convenience method
"""
static func open(url):
	var client = new()
	client.uri = URI.create(url)

	return client._connect()

static func it(url):
	return open(url).get_and_close()

class ErrorResponse:
	var status
	var code
	var uri
	var body
	var headers
	
	func _init(status,code,uri,body,headers):
		self.status=status
		self.code=code
		self.uri=uri
		self.body=body
		self.headers=headers
	
	func _str():
		return "status: "+status+" | code: "+str(code)+" | "+uri

class URI:
	var scheme
	var host
	var port = -1
	var path
	var query = {}

	static func create(url):
		var uri = new()

		if url.begins_with("https://"):
			uri.scheme = "https"
			url = url.right(8)
		elif url.begins_with("http://"):
			uri.scheme = "http"
			url = url.right(7)
		else:
			uri.scheme = "http"

		var slash_pos = url.find("/")
		if slash_pos >= 0:
			uri._path(url.substr(slash_pos, len(url)))

			# URL should now be domain.com:port
			url = url.substr(0, slash_pos)

		var port_pos = url.find(":")
		if port_pos >= 0:
			uri.port = url.substr(port_pos, len(url))

			# URL should now be domain.com
			url = url.substr(0, port_pos)

		# Assign remaining string to host
		uri.host = url

		if int(uri.port) < 0:
			match uri.scheme:
				"https": uri.port = 443
				"http": uri.port = 80
				_: uri.port = 80

		return uri

	func _path(url):
		var query_pos = url.find("?")
		if query_pos >= 0:
			self.query=url.substr(query_pos+1, len(url))
	
			# URL should now be /path/
			url = url.substr(0, query_pos)
		path=url

func path(url):
	uri._path(url)
	return self

func _connect():
	var err=0
	err = connect_to_host(uri.host,uri.port,uri.scheme=="https")
	assert(err == OK)
	emit_signal("connecting")
	while get_status() == HTTPClient.STATUS_CONNECTING or get_status() == HTTPClient.STATUS_RESOLVING:
		poll()
		yield(get_tree(), "idle_frame") 
#        OS.delay_msec(500)
	assert(get_status() == HTTPClient.STATUS_CONNECTED)
	emit_signal("connected")
	return self

func basicauth(user,password):
	assert(user!=null and password!=null)
	header("Authorization : Basic "+ Marshalls.utf8_to_base64(str(user, ":", password)))
	return self

func tokenauth(token):
	assert(token!=null)
	header("Authorization: Token "+token)
	return self

func content_type(value):
	assert(value!=null)
	return header("Content-Type: "+value)

func json_type():
	return content_type("application/json")

func header(header):
	_rest_headers.append(header)
	return self

func headers(headers):
	for header in headers:
		header(header)
	return self

func user_agent(agent):
	_user_agent=agent
	return self

func body(value):
	if value==null:
		_request_body=""
	else:
		_request_body=str(value)

func call(method):
	assert(uri!=null)
	assert(get_status() == HTTPClient.STATUS_CONNECTED)

	var path=uri.path
	if !uri.query.empty():
		path+="?"+uri.query

	print("requesting: "+uri.scheme+"://"+uri.host+":"+str(uri.port)+path)
	print("headers: "+str(_rest_headers))
	print("body: "+self._request_body)

	var err=0

	header("User-Agent: "+_user_agent)

	err = request(method, path, _rest_headers, self._request_body) # Request a page from the site (this one was chunked..)
	assert(err == OK) # Make sure all is OK

	emit_signal("requesting")

	while get_status() == HTTPClient.STATUS_REQUESTING:
        # Keep polling until the request is going on
		poll()
		yield(get_tree(), "idle_frame") 
#        OS.delay_msec(500)

	assert(get_status() == HTTPClient.STATUS_BODY or get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.

	if has_response():
		# If there is a response..
		var headers = get_response_headers_as_dictionary() # Get response headers
		
		var rb = PoolByteArray() # Array that will hold the data
		
		var sta=get_status()
		
		while sta == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			poll()
			var chunk = read_response_body_chunk() # Get a chunk
			if chunk.size() == 0:
		        # Got nothing, wait for buffers to fill a bit
				yield(get_tree(), "idle_frame") 
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer
			emit_signal("body_received",rb.size())
			sta=get_status()
		
		var jsonbody = parse_json(rb.get_string_from_utf8())
		
		emit_signal("completed",jsonbody)
		
		return jsonbody
	else:
		return ErrorResponse.new(get_status(),get_response_code(),uri.scheme+"://"+uri.host+":"+str(uri.port)+path,self._request_body,_rest_headers)

func get(path=null):
	if path!=null:
		self.path(path)
	return call(HTTPClient.METHOD_GET)

func put(path=null):
	if path!=null:
		self.path(path)
	return call(HTTPClient.METHOD_PUT)

func post(path=null):
	if path!=null:
		self.path(path)
	return call(HTTPClient.METHOD_POST)

func delete(path=null):
	if path!=null:
		self.path(path)
	return call(HTTPClient.METHOD_DELETE)

func patch(path=null):
	if path!=null:
		self.path(path)
	return call(HTTPClient.METHOD_PATCH,path)

func get_and_close(path=null):
	var result=get(path)
	close()
	return result

func put_and_close(path=null):
	var result=put(path)
	close()
	return result

func post_and_close(path=null):
	var result=post(path)
	close()
	return result

func delete_and_close(path=null):
	var result=delete(path)
	close()
	return result

func patch_and_close(path=null):
	var result=patch(path)
	close()
	return result
