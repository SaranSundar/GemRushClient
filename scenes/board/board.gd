class_name Board extends Node2D

var room: RoomDTO
var game_state: GameState
var player_stats_hud: Node2D
var PlayerStatsScene = preload("res://scenes/board/PlayerStats.tscn")
var bank_node: Node2D
var player_inventory: Node2D
var host_player: Player

func init(room: RoomDTO, game_state: GameState, host_player: Player):
	self.room = room
	self.game_state = game_state
	self.host_player = host_player
	bank_node = $Bank
	player_stats_hud = $PlayerStatsHUD
	player_inventory = $PlayerInventory
	update_player_stats()
	update_bank()

func update_bank():
	var token_colors = Constants.token_colors
	var bank = game_state.deck.bank
	var i = 0
	for child_node in bank_node.get_children():
		var num_tokens_owned = 0
		if token_colors[i] in bank:
			num_tokens_owned = bank[token_colors[i]]
		child_node.get_node("small").visible = num_tokens_owned > 0
		child_node.get_node("small").texture = load("res://assets/card/small_" + str(num_tokens_owned) + ".png")
		i += 1
		
func update_player_inventory():
	var token_colors = Constants.token_colors
	var player_states = game_state.player_states
	var player_state: PlayerState = player_states[host_player.id]
	var tokens = player_state.tokens
	var cards = player_state.cards
	var i = 0
	for child_node in player_inventory.get_children():
		var num_tokens_owned = 0
		if token_colors[i] in tokens:
			num_tokens_owned = tokens[token_colors[i]]
		child_node.get_node("tokens").get_node("small").visible = num_tokens_owned > 0
		child_node.get_node("tokens").get_node("small").texture = load("res://assets/card/small_" + str(num_tokens_owned) + ".png")
		
		var num_cards_owned = 0
		if i > 0:
			if token_colors[i] in cards:
				num_cards_owned = cards[token_colors[i]]
			child_node.get_node("big").visible = num_cards_owned > 0
			child_node.get_node("big").texture = load("res://assets/card/big_" + str(num_cards_owned) + ".png")
		
		child_node.visible = num_tokens_owned > 0 or num_cards_owned > 0
		
		i += 1

func update_player_stats():
	Constants.delete_children(player_stats_hud)
	for p in room.players:
		var player: Player = p
		var player_stats: PlayerStats = PlayerStatsScene.instance()
		player_stats_hud.add_child(player_stats)
		var player_state: PlayerState = game_state.player_states[player.id]
		player_stats.init(player.id, player_state)
	

