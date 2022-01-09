class_name Board extends Node2D

var room: RoomDTO
var game_state: GameState
var player_stats_hud: Node2D
var PlayerStatsScene = preload("res://scenes/board/PlayerStats.tscn")
var CardScene = preload("res://scenes/card/Card.tscn")
var bank_node: Node2D
var player_inventory: Node2D
var host_player: Player
var deck: Node2D

func init(room: RoomDTO, game_state: GameState, host_player: Player):
	self.room = room
	self.game_state = game_state
	self.host_player = host_player
	bank_node = $Bank
	player_stats_hud = $PlayerStatsHUD
	player_inventory = $PlayerInventory
	deck = $Deck
	init_bank()
	update_player_stats()
	update_bank()
	update_player_inventory()
	update_board()

func setup_on_click_for_bank():
	pass
	
func update_board():
	var board = game_state.deck.board
	var x_spacing = 189
	var y_spacing = 250
	var offset_x = 500
	var offset_y = 50
	var r = 0
	for deck_tier in deck.get_children():
		print(deck_tier.name)
		Constants.delete_children(deck_tier)
		var i = 0
		for card_json in board[deck_tier.name]:
			var card_dto = CardDTO.new()
			card_dto.init_from_json(card_json)
			var card_scene = CardScene.instance()
			card_scene.init_from_json(card_dto)
			card_scene.global_position.x = (i * x_spacing) + offset_x
			card_scene.global_position.y = (r * y_spacing) + offset_y
			deck_tier.add_child(card_scene)
			i += 1
		r += 1
		
	

func update_valid_selections():
	var player_states = game_state.player_states
	var player_state: PlayerState = player_states[host_player.id]
	
	var green_tier = deck.get_node("GreenTier")
	var cannot_purchase_color = Color("FF9999")
	var no_color = Color(1, 1, 1)
	
	for card_nodes in green_tier.get_children():
		var card: Card = card_nodes
		var card_dto: CardDTO = card.card_dto
		if can_purchase_card(card_dto, player_state):
			card.modulate = cannot_purchase_color
		else:
			card.modulate = no_color
		
	
func can_purchase_token(selected_tokens, new_token, player_state: PlayerState):
	var player_token_count = player_state.get_token_count()
	if player_token_count == 10:
		return false
		
	if len(selected_tokens) == 0:
		return true
		
	if len(selected_tokens) == 1:
		if player_token_count == 9:
			return false
		else:
			return true
			
	if len(selected_tokens) == 2:
		if selected_tokens[0] == selected_tokens[1]:
			return false
		else:
			if player_token_count == 8:
				return false
			else:
				return true
				
	if len(selected_tokens) == 3:
		return false
		

func can_purchase_card(card: CardDTO, player_state: PlayerState):
	# Calculate total tokens owned through card discounts and tokens
	var card_cost = card.cost
	var cost = {}
	var gold_needed = 0
	for token_color in card_cost:
		var token_cost = get_value(card_cost, token_color)  - get_value(player_state.cards, token_color)
		if token_cost > 0:
			if token_cost - get_value(player_state.tokens, token_color) <= 0:
				var current_cost = get_value(player_state.tokens, token_color) - token_cost
				cost[token_color] = current_cost
			else:
				cost[token_color] = get_value(player_state.tokens, token_color)
				gold_needed += token_cost - get_value(player_state.tokens, token_color)
				
	var gold_tokens_owned = get_value(player_state.tokens, TokenColor.GOLD)
	
	if gold_needed == 0:
		cost['can_purchase'] = true
	elif gold_tokens_owned >= gold_needed:
		cost[Constants.token_colors[0]] = gold_needed
		cost['can_purchase'] = true
	elif gold_tokens_owned < gold_needed:
		cost['can_purchase'] = false
		
	
func get_value(dictionary, key):
	if key in dictionary:
		return dictionary[key]
	else:
		return 0

func init_bank():
	var bank_node = $Bank
	for token_sprite in bank_node.get_children():
		token_sprite.connect("clicked_sprite", self, "tokens_clicked")

func tokens_clicked(token_name):
	print(token_name)

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
		child_node.visible = num_tokens_owned > 0
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
	

