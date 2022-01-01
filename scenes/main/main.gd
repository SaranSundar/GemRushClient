class_name Main extends Node2D

var host_player: Player
var room: RoomDTO
var game_state: GameState
var menu_handler: MenuHandler
var CreateOrJoinRoomMenuScene = preload("res://scenes/menu/CreateOrJoinRoomMenu.tscn")

const uuid_util = preload('res://scripts/uuid/uuid.gd')

func _ready():
	var uid: String = OS.get_unique_id()
	if uid == "":
		uid = uuid_util.v4()
	host_player = Player.new(uid)
	menu_handler = MenuHandler.new()
	var create_or_join_room_menu = CreateOrJoinRoomMenuScene.instance()
	create_or_join_room_menu.init(host_player, menu_handler)
	menu_handler.load_menu(create_or_join_room_menu, self)
	# http_client = load("res://scripts/http_client/http_request_client.gd").new()
	# add_child(http_client)
	# http_client.connect_room_created_to_room_received(self)
	# http_client.connect_game_state_created_to_game_state_received(self)

func room_received(room_dto):
	print("Room received")
	print(room_dto)
	room = room_dto

func game_state_received(game_state_dto):
	print("Game State received")
	print(game_state_dto)
	game_state = game_state_dto


#func get_room():
#	# Will trigger room_received and update room
#	http_client.get_room_request.get_room(room.id)


#func start_game():
#	http_client.start_game_request.start_game(room.id)
#
#func get_game_state():
#	http_client.get_game_state_request.get_game_state(game_state.id)
#
#func end_turn():
#	var room_id = room.id
#	var player_id = host_player.id
#	var game_state_id = game_state.id
#	var end_turn_action = EndTurnAction.Buying3DifferentTokens
#	var noble: Noble = null
#	var card: Card = null
#	var reserved_card: Card = null
#	var tokens_returned: Array = []
#	var tokens_bought: Array = [TokenColor.BLACK, TokenColor.BLUE, TokenColor.GREEN]
#	http_client.end_turn_request.end_turn(room_id, player_id, game_state_id,
#	 end_turn_action, noble, card, reserved_card, tokens_returned, tokens_bought)
#
#
#func _on_Button_pressed():
#	create_room()
#
#
#func _on_Button2_pressed():
#	get_room()
#
#
#func _on_Button3_pressed():
#	join_room()
#
#
#func _on_Button4_pressed():
#	start_game()
#
#
#func _on_GetGameState_pressed():
#	get_game_state()
#
#
#func _on_EndTurn_pressed():
#	end_turn()
