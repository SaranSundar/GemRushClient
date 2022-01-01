class_name GameState extends Reference

var id: String
# Player id -> PlayerState
# Dict[str, PlayerState]
var player_states: Dictionary
var turn_number: int
# List[Player]
var turn_order: Array
var time_game_started: String
var time_last_move_completed: String
# Could have ties
# winners -> Player ids
var winners: Array
var deck: Deck

func init_from_json(json):
	id = json['id']
	# Player id -> PlayerState
	player_states = json['player_states']
	deck = Deck.new(json['deck'])
	turn_number = json['turn_number']
	turn_order = json['turn_order']
	time_game_started = json['time_game_started']
	time_last_move_completed = json['time_last_move_completed']
	# Could have ties
	# winners -> Player ids
	winners = json['winners']
