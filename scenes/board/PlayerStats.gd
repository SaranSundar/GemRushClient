class_name PlayerStats extends Node2D

var player_id_label: Label

func init(player_id: String):
	player_id_label = $PlayerId
	set_player_id(player_id)

func set_player_id(player_id: String):
	if len(player_id) >= 10:
		player_id = player_id.substr(0, 10)
	player_id_label.text = player_id
