class_name Main extends Node2D

var host_player: Player
var room: RoomDTO
var game_state: GameState
var menu_handler: MenuHandler
var CreateOrJoinRoomMenuScene = preload("res://scenes/menu/CreateOrJoinRoomMenu.tscn")

const uuid_util = preload('res://scripts/uuid/uuid.gd')

func _ready():
	Constants.root = self
	# Will create player id and show ui to create or join game
	var uid: String = OS.get_unique_id()
	if uid == "":
		uid = uuid_util.v4()
	uid = uuid_util.v4()
	host_player = Player.new(uid)
	menu_handler = MenuHandler.new()
	var create_or_join_room_menu = CreateOrJoinRoomMenuScene.instance()
	create_or_join_room_menu.init(host_player, menu_handler)
	menu_handler.load_menu(create_or_join_room_menu, self)
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
