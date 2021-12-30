class_name Main extends Node2D

var http_client
var host_player: Player
var room: RoomDTO

func _ready():
	host_player = Player.new("saranuid")
	http_client = load("res://scripts/http_client/http_request_client.gd").new()
	add_child(http_client)
	http_client.connect_room_created_to_room_received(self)
	http_client.create_room_request.create_room(host_player)

func room_received(room_dto):
	print("Room received")
	print(room_dto)
	room = room_dto
