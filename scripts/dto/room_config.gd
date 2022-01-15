class_name RoomConfig extends Reference

var name
var password
var min_players
var max_players
var creator_id
var score_to_win

func _init(host_player_id):
	name = "ReplaceNameLater"
	password = "ReplacePasswordLater"
	min_players = 2
	max_players = 4
	creator_id = host_player_id
	score_to_win = 15

func to_json():
	return {
		"name": name,
		"password" : password,
		"min_players":  min_players,
		"max_players" : max_players,
		"creator_id" : creator_id,
		"score_to_win":  score_to_win,
	}
