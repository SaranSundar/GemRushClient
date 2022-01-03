class_name Board extends Node2D

var room: RoomDTO
var game_state: GameState

func init(room: RoomDTO, game_state: GameState):
	self.room = room
	self.game_state = game_state
