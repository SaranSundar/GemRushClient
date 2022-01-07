class_name PlayerStats extends Node2D

var player_id_label: Label
var player_state: PlayerState

var gems: Array = []
var token_colors: Array = []

func init(player_id: String, player_state: PlayerState):
	player_id_label = $PlayerId
	gems = [$GoldGem, $BlueGem, $BlackGem, $RedGem, $GreenGem, $WhiteGem]
	token_colors = [TokenColor.GOLD, TokenColor.BLUE, TokenColor.BLACK, TokenColor.RED,
	TokenColor.GREEN, TokenColor.WHITE]
	set_player_id(player_id)
	self.player_state = player_state
	update_tokens(player_state)

func update_tokens(player_state: PlayerState):
	self.player_state = player_state
	for i in range(1, len(token_colors)):
		var num_tokens_owned: int = player_state.tokens[token_colors[i]]
		gems[i].get_node("small").visible = num_tokens_owned > 0
		gems[i].get_node("small").texture = load("res://assets/card/small_" + str(num_tokens_owned) + ".png")
		var num_cards_owned: int = player_state.cards[token_colors[i]]
		gems[i].get_node("big").visible = num_cards_owned > 0
		gems[i].get_node("big").texture = load("res://assets/card/big_" + str(num_cards_owned) + ".png")
		

func set_player_id(player_id: String):
	if len(player_id) >= 10:
		player_id = player_id.substr(0, 10)
	player_id_label.text = player_id
