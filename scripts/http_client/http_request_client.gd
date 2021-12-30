class_name HttpRequestClient extends Node

var create_room_request: CreateRoomRequest
var get_room_request: GetRoomRequest
var join_room_request: JoinRoomRequest

func _init():
	create_room_request = CreateRoomRequest.new()
	get_room_request = GetRoomRequest.new()
	join_room_request = JoinRoomRequest.new()
	add_child(create_room_request)
	add_child(get_room_request)
	add_child(join_room_request)

func connect_room_created_to_room_received(main):
	create_room_request.connect("room_created", main, "room_received")
	get_room_request.connect("room_created", main, "room_received")
	join_room_request.connect("room_created", main, "room_received")

