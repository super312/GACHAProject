extends Node



func _ready():
	talkToServer()

func talkToServer():
	
	$HTTPRequest.request("http://localhost/GODOTWEB/")
	
	pass

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
