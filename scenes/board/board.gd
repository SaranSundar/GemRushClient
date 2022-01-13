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
var selection = []
var selection_node: Node2D
var http_client: HttpRequestClient
var end_turn_button: Button

enum GameState {
	NOT_MY_TURN,
	MY_TURN,
	GOLD_TOKEN_SELECTED,
	TOKENS_SELECTED,
	CARD_SELECTED
}

var current_game_state = GameState.NOT_MY_TURN

func init(room: RoomDTO, game_state: GameState, host_player: Player):
	self.room = room
	self.game_state = game_state
	self.host_player = host_player
	bank_node = $Bank
	player_stats_hud = $PlayerStatsHUD
	player_inventory = $PlayerInventory
	end_turn_button = $Control/EndTurn
	deck = $Deck
	selection_node = $Selection
	http_client = HttpRequestClient.new()
	add_child(http_client)
	http_client.connect_game_state_created_to_game_state_received(self)
	setup_clickable_sprites()
	init_bank()
	update_player_stats()
	update_bank()
	update_player_inventory()
	update_board()

func game_state_received(game_state_dto):
	print("Game State received")
	game_state = game_state_dto
	print(game_state.player_states)
	for key in game_state.player_states:
		print(game_state.player_states[key].data)
	selection = []
	current_game_state = GameState.NOT_MY_TURN
	var game_player_id = game_state.turn_order[game_state.turn_number].id
	print("Game player id " + str(game_player_id))
	print("Current player id " + str(host_player.id))
	update_board()


func update_game_state():
	if current_game_state == GameState.NOT_MY_TURN:
		end_turn_button.visible = false
		if game_state.turn_order[game_state.turn_number].id == host_player.id:
			current_game_state = GameState.MY_TURN
			end_turn_button.visible = true

func _process(delta):
	update_game_state()
	update_selection()
	
	update_player_stats()
	update_bank()
	update_player_inventory()

func update_selection():
	var card_node = selection_node.get_node("card")
	card_node.visible = false
	if current_game_state == GameState.NOT_MY_TURN or current_game_state == GameState.MY_TURN:
		for i in range(1, 4):
			var token_node = selection_node.get_node("token" + str(i))
			var cancel_node = selection_node.get_node("cancel" + str(i))
			token_node.visible = false
			cancel_node.visible = false
	
	elif current_game_state == GameState.TOKENS_SELECTED:
		for i in range(1, 4):
			var token_node = selection_node.get_node("token" + str(i))
			var cancel_node = selection_node.get_node("cancel" + str(i))
			token_node.visible = false
			cancel_node.visible = false
			if i - 1 < len(selection):
				var token_color: String = selection[i-1]
				token_node.visible = true
				cancel_node.visible = true
				token_node.texture = load("res://assets/card/" + token_color.to_lower() + "_token.png")
	
	elif current_game_state == GameState.GOLD_TOKEN_SELECTED:
		var token_node = selection_node.get_node("token1")
		var cancel_node = selection_node.get_node("cancel1")
		token_node.visible = true
		cancel_node.visible = true
		token_node.texture = load("res://assets/card/gold_token.png")
		if len(selection) == 2:
			card_node.init_from_json(selection[1])
			card_node.visible = true
	
	elif current_game_state == GameState.CARD_SELECTED:
		var token_node = selection_node.get_node("token1")
		var cancel_node = selection_node.get_node("cancel1")
		token_node.visible = false
		cancel_node.visible = true
		card_node.init_from_json(selection[0])
		card_node.visible = true
			
	

func setup_clickable_sprites():
	$Selection/cancel1/Area2D.connect("clicked_sprite", self, "received_cancel_click")
	$Selection/cancel2/Area2D.connect("clicked_sprite", self, "received_cancel_click")
	$Selection/cancel3/Area2D.connect("clicked_sprite", self, "received_cancel_click")
	$Bank/GoldTokens/Area2D.connect("clicked_sprite", self, "received_tokens_click")
	$Bank/BlackTokens/Area2D.connect("clicked_sprite", self, "received_tokens_click")
	$Bank/RedTokens/Area2D.connect("clicked_sprite", self, "received_tokens_click")
	$Bank/GreenTokens/Area2D.connect("clicked_sprite", self, "received_tokens_click")
	$Bank/BlueTokens/Area2D.connect("clicked_sprite", self, "received_tokens_click")
	$Bank/WhiteTokens/Area2D.connect("clicked_sprite", self, "received_tokens_click")

func received_tokens_click(sprite_name):
	print("CGS before: " + str(current_game_state))
	if current_game_state == GameState.NOT_MY_TURN:
		return
	elif current_game_state == GameState.CARD_SELECTED:
		return
	elif current_game_state == GameState.GOLD_TOKEN_SELECTED:
		return
	elif sprite_name == TokenColor.GOLD and current_game_state != GameState.MY_TURN:
		return
	var player_states = game_state.player_states
	var player_state: PlayerState = player_states[host_player.id]
	#selected_tokens, new_token, player_state: PlayerState
	if can_purchase_token(selection, sprite_name, player_state):
		var bank = game_state.deck.bank
		bank[sprite_name] -= 1
		selection.append(sprite_name)
	
	if sprite_name == TokenColor.GOLD:
		current_game_state = GameState.GOLD_TOKEN_SELECTED
	else:
		current_game_state = GameState.TOKENS_SELECTED
	
	print("CGS after: " + str(current_game_state))
	print(sprite_name)
	

func received_cancel_click(selection_index_str):
	var bank = game_state.deck.bank
	var selection_index = int(selection_index_str)
	if current_game_state == GameState.GOLD_TOKEN_SELECTED:
		bank[Constants.token_colors[0]] += 1
		selection = []
	else:
		selection.remove(selection_index)
		if current_game_state == GameState.TOKENS_SELECTED:
			bank[selection[selection_index]] += 1
			
	if len(selection) == 0:
		current_game_state = GameState.MY_TURN
	print("Index is " + selection_index_str)
	print(selection)

func received_card_click(card_dto: CardDTO):
	print(card_dto.color)
	print(card_dto.cost)
	if current_game_state == GameState.GOLD_TOKEN_SELECTED:
		if len(selection) == 1:
			selection.append(card_dto)
	elif current_game_state == GameState.MY_TURN:
		selection.append(card_dto)
		current_game_state = GameState.CARD_SELECTED
	
func update_board():
	var board = game_state.deck.board
	var x_spacing = 189
	var y_spacing = 250
	var offset_x = 500
	var offset_y = 50
	var r = 0
	for deck_tier in deck.get_children():
		Constants.delete_children(deck_tier)
		var i = 0
		for card_json in board[deck_tier.name]:
			var card_dto = CardDTO.new()
			card_dto.init_from_json(card_json)
			var card_scene = CardScene.instance()
			card_scene.init_from_json(card_dto)
			card_scene.connect("clicked_card", self, "received_card_click")
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
	var bank = game_state.deck.bank
	if bank[new_token] <= 0:
		return false
		
	if bank[Constants.token_colors[0]] == 3 and new_token == "GOLD":
		return false
	
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
		if selected_tokens[0] == selected_tokens[1] or new_token in selected_tokens:
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
				num_cards_owned = len(cards[token_colors[i]])
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
	



func _on_EndTurn_pressed():
	# room_id, player_id, game_state_id, end_turn_action, noble: Noble,
	# card: Card, reserved_card: Card, tokens_returned: Array, tokens_bought: Array
	if current_game_state == GameState.CARD_SELECTED:
		http_client.end_turn_request.end_turn(
			room.id,
			host_player.id,
			game_state.id,
			EndTurnAction.BuyingCard,
			null,
			selection[0],
			null,
			[],
			[]
		)
	elif current_game_state == GameState.GOLD_TOKEN_SELECTED:
		if len(selection) == 2:
			http_client.end_turn_request.end_turn(
				room.id,
				host_player.id,
				game_state.id,
				EndTurnAction.BuyingGoldToken,
				null,
				null,
				selection[1],
				[],
				[selection[0]]
			)
	elif current_game_state == GameState.TOKENS_SELECTED:
		http_client.end_turn_request.end_turn(
			room.id,
			host_player.id,
			game_state.id,
			EndTurnAction.Buying3DifferentTokens,
			null,
			null,
			null,
			[],
			selection
		)


func _on_SkipTurn_pressed():
	pass # Replace with function body.
