class_name EndTurnRequest extends HTTPRequest

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
	self.request(url, headers, false, HTTPClient.METHOD_POST, query)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	# print(json.result)
	print(headers)
	print(result)
	print(response_code)
	var game_state = GameState.new()
	game_state.init_from_json(json.result)
	emit_signal("game_state_created", game_state)

func end_turn(room_id, player_id, game_state_id, end_turn_action, noble: Noble, card: CardDTO, reserved_card: CardDTO, tokens_returned: Array, tokens_bought: Array):
	var end_turn_url = self.host_ip + ":" + self.port + ApiMethods.END_TURN
	var card_data = null
	if card != null:
		card_data = card.get_as_json()
	var reserved_card_data = null
	if reserved_card != null:
		reserved_card_data = reserved_card.get_as_json()
	var reserved_noble_data = null
	if noble != null:
		reserved_noble_data = noble.get_as_json()
	var payload = {
			"room_id": room_id,
			"player_id": player_id,
			"game_state_id": game_state_id,
			"action": end_turn_action,
			"payload": {
				"bought_noble": reserved_noble_data,
				"bought_card": card_data,
				"reserved_card": reserved_card_data,
				"tokens_returned": tokens_returned,
				"tokens_bought": tokens_bought
			}
		}
	print("End turn request url is")
	print(end_turn_url)
	print(payload)
	make_post_request(end_turn_url, payload, true)
