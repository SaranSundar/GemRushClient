class_name CreateRoomRequest extends BaseHTTPRequest


signal room_created(room_dto)


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
	print(json.result)
	print(headers)
	print(result)
	print(response_code)
	var room_dto = RoomDTO.new()
	room_dto.init_from_json(json.result)
	emit_signal("room_created", room_dto)

func create_room(room_config: RoomConfig):
	var create_room_url = self.host_ip + ":" + self.port + ApiMethods.CREATE_ROOM
	var payload = room_config.to_json()
	print("Create Room request url is")
	print(create_room_url)
	print(payload)
	make_post_request(create_room_url, payload, true)
