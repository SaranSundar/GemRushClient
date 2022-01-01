class_name StartGameRequest extends HTTPRequest

const host_ip: String = "http://207.246.122.46"
const port: String = "9378"

signal game_state_created(game_state_dto)


func _ready():
	self.connect("request_completed", self, "_on_request_completed")

func make_post_request(url, data_to_send, use_ssl):
	# Convert data to json string:
	var query = JSON.print(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	self.request(url, headers, true, HTTPClient.METHOD_POST, query)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	print(headers)
	print(result)
	print(response_code)
	var game_state = GameState.new()
	game_state.init_from_json(json.result)
	emit_signal("game_state_created", game_state)

func start_game(room_id):
	var start_game_url = self.host_ip + ":" + self.port + ApiMethods.START_GAME
	var payload = {
			'room_id': room_id
		}
	print("Start game request url is")
	print(start_game_url)
	print(payload)
	make_post_request(start_game_url, payload, true)
