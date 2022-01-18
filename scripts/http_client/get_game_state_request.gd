class_name GetGameStateRequest extends BaseHTTPRequest


signal game_state_created(game_state_dto)


func _ready():
	self.connect("request_completed", self, "_on_request_completed")

func make_get_request(url):
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	self.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(headers)
	print(result)
	print(response_code)
	var game_state = GameState.new()
	game_state.init_from_json(json.result)
	emit_signal("game_state_created", game_state)

func get_game_state(game_state_id):
	var get_game_state_url = self.host_ip + ":" + self.port +  ApiMethods.GET_GAME_STATE + "/" + game_state_id
	make_get_request(get_game_state_url)
