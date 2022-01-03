class_name CreateRoomLobby extends Control

var room_id_input: LineEdit
var players_joined: VBoxContainer
var host_player: Player
var start_game_button: Button
var http_client: HttpRequestClient
var game_state: GameState
var menu_handler: MenuHandler

var room: RoomDTO

var start_time = OS.get_ticks_msec()

func init(room_dto: RoomDTO, player: Player, menu_handler: MenuHandler):
	self.menu_handler = menu_handler
	room_id_input = $Panel/RoomIdInput
	room_id_input.text = room_dto.id
	players_joined = $Panel/PlayersJoined
	start_game_button = $Panel/StartGame
	room = room_dto
	host_player = player
	if room.owner.id != host_player.id:
		start_game_button.disabled = true
		start_game_button.visible = false
	
	http_client = HttpRequestClient.new()
	add_child(http_client)
	http_client.connect_room_created_to_room_received(self)
	http_client.connect_game_state_created_to_game_state_received(self)
	update_players_joined()
	
	start_time = OS.get_ticks_msec()

func _on_Timer_timeout():
	print("Calling get room")
	http_client.get_room_request.get_room(room.id)

func _process(delta):
	var elapsed_time = OS.get_ticks_msec() - start_time
	if elapsed_time > 10000:
		_on_Timer_timeout()
		start_time = OS.get_ticks_msec()

func room_received(room_dto):
	print("Room received")
	print(room_dto)
	room = room_dto
	update_players_joined()
	if room.game_state_id != "" and room.game_state_id != null:
		http_client.get_game_state_request.get_game_state(room.game_state_id)

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func game_state_received(game_state_dto):
	print("Game State received")
	print(game_state_dto)
	game_state = game_state_dto
	menu_handler.load_board(game_state, room)

func create_player_container(player: Player):
	var player_id = Label.new()
	player_id.text = "Player Id: " + player.id
	if player.id == room.owner.id:
		player_id.text += " (Host)"
	return player_id

func update_players_joined():
	if room == null:
		return
	
	delete_children(players_joined)
		
	for p in room.players:
		var player: Player = p
		players_joined.add_child(create_player_container(player))
		
		


func _on_StartGame_pressed():
	http_client.start_game_request.start_game(room.id)
