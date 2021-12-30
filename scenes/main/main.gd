class_name Main extends Node2D

var http_client
var host_player: Player
var room: RoomDTO

const uuid_util = preload('res://scripts/uuid/uuid.gd')

func _ready():
	var uid: String = OS.get_unique_id()
	if uid == "":
		uid = uuid_util.v4()
	host_player = Player.new(uid)
	http_client = load("res://scripts/http_client/http_request_client.gd").new()
	add_child(http_client)
	http_client.connect_room_created_to_room_received(self)

func room_received(room_dto):
	print("Room received")
	print(room_dto)
	room = room_dto

func create_room():
	http_client.create_room_request.create_room(host_player)

func get_room():
	# Will trigger room_received and update room
	http_client.get_room_request.get_room(room)

func join_room():
	var other_player = Player.new(uuid_util.v4())
	http_client.join_room_request.join_room(other_player, room.name, room.password, room.id)


func _on_Button_pressed():
	create_room()


func _on_Button2_pressed():
	get_room()


func _on_Button3_pressed():
	join_room()
