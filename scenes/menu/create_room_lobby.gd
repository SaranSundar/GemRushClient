class_name CreateRoomLobby extends Control

var room_id_input: LineEdit
var players_joined: VBoxContainer
var host_player: Player
var start_game_button: Button
var http_client: HttpRequestClient
var game_state: GameState

var room: RoomDTO

var timer: Timer

func init(room_dto: RoomDTO, player: Player):
	room_id_input = $Panel/RoomIdInput
	room_id_input.text = room_dto.id
	players_joined = $PlayersJoined
	start_game_button = $StartGame
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
	
	timer = $Timer
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.set_wait_time(5)
	timer.set_paused(false)
	timer.set_one_shot(false) # Make sure it loops
	timer.start()

func _on_Timer_timeout():
	print("Calling get room")
	http_client.get_room_request.get_room(room.id)  

func _process(delta):
	pass

func room_received(room_dto):
	print("Room received")
	print(room_dto)
	room = room_dto
	update_players_joined()
	if room.game_state_id != "" and room.game_state_id != null:
		timer.stop()
		timer.emit_signal("timeout")
		timer.queue_free()
		http_client.get_game_state_request.get_game_state(room.game_state_id)

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func game_state_received(game_state_dto):
	print("Game State received")
	print(game_state_dto)
	game_state = game_state_dto

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
		
		
