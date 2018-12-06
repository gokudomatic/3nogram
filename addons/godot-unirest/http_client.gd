extends HTTPClient

signal connected()
signal connecting()
signal disconnected()
signal resolving()
signal resolve_failed()
signal body_received(bytes)
signal ssl_handshake_failed()

var uri

var _user_agent="Pirulo/1.0 (Godot)"
var _rest_headers=[]

"""
Factory convenience method
"""
static func create_client(url):
	var client = new()
	client.uri = URI.create(url)

	return client

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
			path(url.substr(slash_pos, len(url)))

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

func path(url):
	var query_pos = url.find("?")
	if query_pos >= 0:
		# q: name=Bob&age=30
		var q = url.substr(query_pos, len(url))

		# params: ["name=Bob", "age=30"]
		var params = q.split("&")

		# query: { "name": "Bob", "age": 30 }
		for i in params:
			var parts = params[i].split("=")
			uri.query[parts[0]] = parts[1]

		# URL should now be /path/
		url = url.substr(0, query_pos)
	uri.path=url
	return self

func connect():
	var err=0
	err = connect_to_host(uri.host,uri.port,true)
	assert(err == OK) 
	while get_status() == HTTPClient.STATUS_CONNECTING or get_status() == HTTPClient.STATUS_RESOLVING:
        poll()
        OS.delay_msec(500)
	assert(get_status() == HTTPClient.STATUS_CONNECTED)
	return self



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

func request(method,body=""):
	assert(uri!=null)
	assert(get_status() == HTTPClient.STATUS_CONNECTED)
	
	var err=0
	
	header("User-Agent: "+_user_agent)

	err = http.request(method, http.uri.path, _rest_headers, body) # Request a page from the site (this one was chunked..)
	assert(err == OK) # Make sure all is OK

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
        # Keep polling until the request is going on
        http.poll()
        OS.delay_msec(500)

	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.
		
	if http.has_response():
		# If there is a response..
		headers = http.get_response_headers_as_dictionary() # Get response headers
		
		var rb = PoolByteArray() # Array that will hold the data
		
		while http.get_status() == HTTPClient.STATUS_BODY:
		    # While there is body left to be read
		    http.poll()
		    var chunk = http.read_response_body_chunk() # Get a chunk
		    if chunk.size() == 0:
		        # Got nothing, wait for buffers to fill a bit
		        OS.delay_usec(1000)
		    else:
		        rb = rb + chunk # Append to read buffer
		
		var jsonbody = parse_json(rb.get_string_from_utf8())
		return jsonbody

func get():
	return request(HTTPClient.METHOD_GET)

func put():
	return request(HTTPClient.METHOD_PUT)

func post():
	return request(HTTPClient.METHOD_POST)

func delete():
	return request(HTTPClient.METHOD_DELETE)

func patch():
	return request(HTTPClient.METHOD_PATCH)
