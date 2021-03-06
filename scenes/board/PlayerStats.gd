class_name PlayerStats extends Node2D

var player_id_label: Label
var player_state: PlayerState

var points: Sprite

var gems: Array = []
var token_colors: Array = []

var button: Button

var player_id

var player_turn_sprite: Sprite

signal clicked_player_stats(player_id)


func init(player_id: String, player_state: PlayerState, is_player_turn: bool):
	player_id_label = $PlayerId
	player_turn_sprite = $Cancel
	player_turn_sprite.visible = is_player_turn
	points = $points
	button = $Control/Button
	gems = [$GoldGem, $BlueGem, $BlackGem, $RedGem, $GreenGem, $WhiteGem]
	token_colors = [TokenColor.GOLD, TokenColor.BLUE, TokenColor.BLACK, TokenColor.RED,
	TokenColor.GREEN, TokenColor.WHITE]
	set_player_id(player_id)
	self.player_state = player_state
	update_tokens(player_state)

func update_tokens(player_state: PlayerState):
	self.player_state = player_state
	var total_points = player_state.get_total_points()
	points.visible = total_points > 0
	if total_points > 0:
		points.texture = load("res://assets/card/big_" + str(total_points) + ".png")
	for i in range(0, len(token_colors)):
		var num_tokens_owned: int = player_state.tokens[token_colors[i]]
		gems[i].get_node("small").visible = num_tokens_owned > 0
		if num_tokens_owned > 0:
			gems[i].get_node("small").texture = load("res://assets/card/small_" + str(num_tokens_owned) + ".png")
		var num_cards_owned: int = 0
		if i != 0:
			if token_colors[i] in player_state.cards:
				num_cards_owned = len(player_state.cards[token_colors[i]])
			gems[i].get_node("big").visible = num_cards_owned > 0
			if num_cards_owned > 0:
				gems[i].get_node("big").texture = load("res://assets/card/big_" + str(num_cards_owned) + ".png")
		if num_cards_owned == 0 and num_tokens_owned == 0:
			gems[i].visible = false
		else:
			gems[i].visible = true
		

func set_player_id(player_id: String):
	self.player_id = player_id
	if len(player_id) >= 10:
		player_id = player_id.substr(0, 10)
	player_id_label.text = player_id


func _on_Button_pressed():
	emit_signal("clicked_player_stats", self.player_id)
