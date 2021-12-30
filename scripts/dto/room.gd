class_name RoomDTO extends Reference

var id: String
var name: String
var password: String
var min_players: int
var max_players: int
# Is of type Player
var owner: Player
var players: Array
var time_room_created: Dictionary
var game_state_id: String
var score_to_win: int

func init_from_json(json):
	id = json['id']
	name = json['name']
	password = json['password']
	min_players = json['min_players']
	max_players = json['max_players']
	owner = Player.new(json['owner']['id'])
	var json_players = json['players']
	players = []
	for jp in json_players:
		var player = Player.new(jp.id)
		players.append(player)
	# TODO: parse time created
	time_room_created = {}
	game_state_id = json['game_state_id']
	score_to_win = json['score_to_win']
	

