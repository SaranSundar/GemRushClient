class_name Main extends Node2D

var http_client: HttpRequestClient
var host_player: Player
var room: RoomDTO
var game_state: GameState


const uuid_util = preload('res://scripts/uuid/uuid.gd')

func _ready():
	var uid: String = OS.get_unique_id()
	if uid == "":
		uid = uuid_util.v4()
	host_player = Player.new(uid)
	http_client = load("res://scripts/http_client/http_request_client.gd").new()
	add_child(http_client)
	http_client.connect_room_created_to_room_received(self)
	http_client.connect_game_state_created_to_game_state_received(self)

func room_received(room_dto):
	print("Room received")
	print(room_dto)
	room = room_dto

func game_state_received(game_state_dto):
	print("Game State received")
	print(game_state_dto)
	game_state = game_state_dto

func create_room():
	http_client.create_room_request.create_room(host_player.id)

func get_room():
	# Will trigger room_received and update room
	http_client.get_room_request.get_room(room.id)

func join_room():
	var other_player = Player.new(uuid_util.v4())
	http_client.join_room_request.join_room(other_player.id, room.name, room.password, room.id)

func start_game():
	http_client.start_game_request.start_game(room.id)

func get_game_state():
	http_client.get_game_state_request.get_game_state(game_state.id)


func _on_Button_pressed():
	create_room()


func _on_Button2_pressed():
	get_room()


func _on_Button3_pressed():
	join_room()


func _on_Button4_pressed():
	start_game()


func _on_GetGameState_pressed():
	get_game_state()
