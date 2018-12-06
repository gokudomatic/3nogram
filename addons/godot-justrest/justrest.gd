extends Node

signal completed

export(String) var result=null

func it(url):
	$HTTPRequest.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	self.result=json.result
	self.emit_signal("completed")
