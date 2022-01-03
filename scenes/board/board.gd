class_name Board extends Node2D

var room: RoomDTO
var game_state: GameState
var player_stats_hud: Node2D
var PlayerStatsScene = preload("res://scenes/board/PlayerStats.tscn")

func init(room: RoomDTO, game_state: GameState):
	self.room = room
	self.game_state = game_state
	player_stats_hud = $PlayerStatsHUD
	update_player_stats()

func update_player_stats():
	Constants.delete_children(player_stats_hud)
	for p in room.players:
		var player: Player = p
		var player_stats: PlayerStats = PlayerStatsScene.instance()
		player_stats_hud.add_child(player_stats)
		player_stats.init(player.id)
	

