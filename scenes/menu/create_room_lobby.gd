class_name CreateRoomLobby extends Control

var room_id_input

func init(room: RoomDTO):
	room_id_input = $Panel/RoomIdInput
	room_id_input.text = room.id
