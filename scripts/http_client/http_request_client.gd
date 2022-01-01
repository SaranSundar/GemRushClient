class_name HttpRequestClient extends Node

var create_room_request: CreateRoomRequest
var get_room_request: GetRoomRequest
var join_room_request: JoinRoomRequest
var start_game_request: StartGameRequest
var get_game_state_request: GetGameStateRequest

func _init():
	create_room_request = CreateRoomRequest.new()
	get_room_request = GetRoomRequest.new()
	join_room_request = JoinRoomRequest.new()
	start_game_request = StartGameRequest.new()
	get_game_state_request = GetGameStateRequest.new()
	add_child(create_room_request)
	add_child(get_room_request)
	add_child(join_room_request)
	add_child(start_game_request)
	add_child(get_game_state_request)

func connect_room_created_to_room_received(main):
	create_room_request.connect("room_created", main, "room_received")
	get_room_request.connect("room_created", main, "room_received")
	join_room_request.connect("room_created", main, "room_received")

func connect_game_state_created_to_game_state_received(main):
	start_game_request.connect("game_state_created", main, "game_state_received")
	get_game_state_request.connect("game_state_created", main, "game_state_received")

