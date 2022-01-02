class_name CreateOrJoinRoomMenu extends Control

var http_client: HttpRequestClient
var host_player: Player
onready var room_code_input: LineEdit = $Panel/RoomCodeInput
var room: RoomDTO
var menu_handler: MenuHandler
var CreateRoomLobbyScene = preload("res://scenes/menu/CreateRoomLobby.tscn")

func init(player: Player, menu_handler_in):
	menu_handler = menu_handler_in
	host_player = player
	http_client = HttpRequestClient.new()
	add_child(http_client)
	http_client.connect_room_created_to_room_received(self)
	# http_client.connect_game_state_created_to_game_state_received(self)

func room_received(room_dto):
	print("Room received")
	print(room_dto)
	room = room_dto
	var create_room_lobby = CreateRoomLobbyScene.instance()
	create_room_lobby.init(room, host_player)
	menu_handler.load_menu(create_room_lobby, self)

func create_room():
	var room_config = RoomConfig.new(host_player.id)
	http_client.create_room_request.create_room(room_config)

func join_room():
	# TODO: Get actual name and password from ui instead of hardcoding it
	var room_config = RoomConfig.new(host_player.id)
	http_client.join_room_request.join_room(host_player.id, room_config.name, room_config.password, room_code_input.text)


func _on_CreateRoom_pressed():
	create_room()


func _on_JoinRoom_pressed():
	join_room()
