class_name GetRoomRequest extends HTTPRequest

const host_ip: String = "http://207.246.122.46"
const port: String = "9378"

signal room_created(room_dto)


func _ready():
	self.connect("request_completed", self, "_on_request_completed")

func make_get_request(url):
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	self.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	print(headers)
	print(result)
	print(response_code)
	var room_dto = RoomDTO.new()
	room_dto.init_from_json(json.result)
	emit_signal("room_created", room_dto)

func get_room(room_id):
	var get_room_url = self.host_ip + ":" + self.port +  ApiMethods.GET_ROOM + "/" + room_id
	make_get_request(get_room_url)
