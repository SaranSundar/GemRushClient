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
var reserved_cards_node: Node2D
var winners_label: Label
var nobles_node: Node2D
var particles_node: Node2D
var discard_button: Button
var rules_scene: Rules

var timer_checkout_ms = 7000

var start_time = OS.get_ticks_msec()

enum GameState {
	NOT_MY_TURN,
	MY_TURN,
	GOLD_TOKEN_SELECTED,
	TOKENS_SELECTED,
	CARD_SELECTED,
	RESERVED_CARD_SELECTED
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
	discard_button = $Control/Discard
	deck = $Deck
	selection_node = $Selection
	reserved_cards_node = $ReservedCards
	winners_label = $Winners/Label
	nobles_node = $Nobles
	particles_node = $Particles
	rules_scene = $Rules
	rules_scene.visible = false
	http_client = HttpRequestClient.new()
	add_child(http_client)
	http_client.connect_game_state_created_to_game_state_received(self)
	setup_clickable_sprites()
	update_player_stats()
	update_bank()
	update_player_inventory()
	update_board()
	display_winners()
	start_time = OS.get_ticks_msec()

func close_rules():
	print("Cancel received")
	rules_scene.visible = false

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
	if game_state.turn_order[game_state.turn_number].id == host_player.id:
		display_particles()
	update_board()
	display_winners()
	start_time = OS.get_ticks_msec()

func display_winners():
	var winners_text = "Winner is: "
	for winner in game_state.winners:
		winners_text += winner
		if len(game_state.winners) > 1:
			winners_text += ", "
	winners_label.text += "!"
	winners_label.text = winners_text
	winners_label.visible = len(game_state.winners) >= 1

func display_particles():
	particles_node.visible = true
	for node in particles_node.get_children():
		var particle: Particles2D = node
		particle.set_emitting(true)
		particle.visible = true


func update_game_state():
	if game_state.turn_order[game_state.turn_number].id != host_player.id:
		current_game_state = GameState.NOT_MY_TURN
	
	if current_game_state == GameState.NOT_MY_TURN:
		end_turn_button.visible = false
		discard_button.visible = false
		if game_state.turn_order[game_state.turn_number].id == host_player.id:
			current_game_state = GameState.MY_TURN
			end_turn_button.visible = true
			var player_states = game_state.player_states
			var player_state: PlayerState = player_states[host_player.id]
			if player_state.get_token_count() >= 8:
				discard_button.visible = true
			start_time = OS.get_ticks_msec()
	
	if current_game_state != GameState.NOT_MY_TURN:
		if len(selection) == 0:
			current_game_state = GameState.MY_TURN
			start_time = OS.get_ticks_msec()

func _on_Timer_timeout():
	print("Calling get game state")
	http_client.get_game_state_request.get_game_state(game_state.id)

func _process(delta):
	update_game_state()
	update_selection()
	
	update_player_stats()
	update_bank()
	update_player_inventory()
	
	
	if current_game_state == GameState.NOT_MY_TURN:
		var elapsed_time = OS.get_ticks_msec() - start_time
		if elapsed_time > timer_checkout_ms:
			_on_Timer_timeout()
			start_time = OS.get_ticks_msec()

func update_selection():
	var card_node = selection_node.get_node("card")
	var noble_node = selection_node.get_node("noble")
	card_node.visible = false
	noble_node.visible = false
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
				if selection[i-1] is Noble:
					continue
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
	
	elif current_game_state == GameState.CARD_SELECTED or current_game_state == GameState.RESERVED_CARD_SELECTED:
		var token_node = selection_node.get_node("token1")
		var cancel_node = selection_node.get_node("cancel1")
		token_node.visible = false
		cancel_node.visible = true
		card_node.init_from_json(selection[0])
		card_node.visible = true
	
	var selected_noble = null
	for option in selection:
		if option is Noble:
			selected_noble = option
	if selected_noble != null:
		noble_node.init_from_json(selected_noble)
		noble_node.visible = true
			
	

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
	
	for noble in $Nobles.get_children():
		noble.connect("clicked_card", self, "received_noble_click")
	
	for reserved_c in $ReservedCards.get_children():
		reserved_c.connect("clicked_card", self, "received_reserved_card_click")
	
	$Rules.connect("clicked_cancel", self, "close_rules")

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
	elif current_game_state == GameState.TOKENS_SELECTED:
		bank[selection[selection_index]] += 1
		selection.remove(selection_index)
		var noble_index = -1
		for i in range(len(selection)):
			if selection[i] is Noble:
				noble_index = i
				break
		if noble_index != -1:
			selection.remove(noble_index)
	elif current_game_state == GameState.CARD_SELECTED:
		selection = []
	elif current_game_state == GameState.RESERVED_CARD_SELECTED:
		selection = []
	
	if len(selection) == 0:
		current_game_state = GameState.MY_TURN
	print("Index is " + selection_index_str)
	print(selection)

func received_reserved_card_click(card_dto: CardDTO):
	print(card_dto.color)
	print(card_dto.cost)
	if current_game_state == GameState.MY_TURN:
		var player_states = game_state.player_states
		var player_state: PlayerState = player_states[host_player.id]
		var player_cost = can_purchase_card(card_dto, player_state)
		if player_cost['can_purchase']:
			card_dto.player_cost = player_cost
			selection.append(card_dto)
			current_game_state = GameState.RESERVED_CARD_SELECTED

func received_card_click(card_dto: CardDTO):
	print(card_dto.color)
	print(card_dto.cost)
	if current_game_state == GameState.GOLD_TOKEN_SELECTED:
		if len(selection) == 1:
			selection.append(card_dto)
	elif current_game_state == GameState.MY_TURN:
		var player_states = game_state.player_states
		var player_state: PlayerState = player_states[host_player.id]
		var player_cost = can_purchase_card(card_dto, player_state)
		if player_cost['can_purchase']:
			card_dto.player_cost = player_cost
			selection.append(card_dto)
			current_game_state = GameState.CARD_SELECTED

func received_noble_click(noble_dto: Noble):
	print(noble_dto.cost)
	print(noble_dto.points)
	if current_game_state == GameState.CARD_SELECTED or current_game_state == GameState.RESERVED_CARD_SELECTED:
		if can_purchase_noble(noble_dto, selection[0]):
			selection.append(noble_dto)
	elif current_game_state == GameState.TOKENS_SELECTED:
		if can_purchase_noble(noble_dto, null):
			selection.append(noble_dto)
	elif current_game_state == GameState.GOLD_TOKEN_SELECTED:
		# Gold token and reserved card selected
		if len(selection) == 2:
			if can_purchase_noble(noble_dto, null):
				selection.append(noble_dto)

func can_purchase_noble(noble_dto: Noble, card_dto: CardDTO):
	var player_state: PlayerState = game_state.player_states[host_player.id]
	return player_state.can_purchase_noble(noble_dto, card_dto)
		
func update_board():
	var player_states = game_state.player_states
	var player_state: PlayerState = player_states[host_player.id]
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
			card_scene.position.x = (i * x_spacing) + offset_x
			card_scene.position.y = (r * y_spacing) + offset_y
			card_scene.update_card_shader(can_purchase_card(card_dto, player_state))
			deck_tier.add_child(card_scene)
			i += 1
		r += 1
	var i = 0
	for reserved_card_node in reserved_cards_node.get_children():
		var reserved_card_scene: Card = reserved_card_node
		if i < len(player_state.reserved_cards):
			var card_dto = CardDTO.new()
			card_dto.init_from_json(player_state.reserved_cards[i])
			reserved_card_scene.init_from_json(card_dto)
			reserved_card_scene.update_card_shader(can_purchase_card(card_dto, player_state))
			reserved_card_scene.visible = true
		else:
			reserved_card_scene.visible = false
		i += 1
	
	i = 0
	for noble_card in nobles_node.get_children():
		var noble_card_scene = noble_card
		if i < len(game_state.deck.noble_cards):
			var noble_dto = Noble.new()
			noble_dto.init_from_json(game_state.deck.noble_cards[i])
			noble_card_scene.init_from_json(noble_dto)
			noble_card_scene.visible = true
		else:
			noble_card_scene.visible = false
		i += 1
		
	
func can_purchase_token(selected_tokens, new_token, player_state: PlayerState):
	var bank = game_state.deck.bank
	# If bank has no tokens left
	if bank[new_token] <= 0:
		return false
	
	# Can only have 3 cards reserved at once
	if new_token == "GOLD" and len(player_state.reserved_cards) == 3:
		return false
		
	
	# Must have at least 4 tokens of a color left to grab 2 of that color
	if len(selected_tokens) == 1:
		if selected_tokens[0] == new_token:
			return bank[new_token] >= 3
	
	# If player hand is full with 10 tokens
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
		var card_value = get_value(card_cost, token_color)
		var player_value = len(player_state.cards[token_color])
		# Cost of card to player
		var token_cost = card_value - player_value
		if token_cost > 0:
			var player_owned_tokens = get_value(player_state.tokens, token_color)
			if token_cost - player_owned_tokens <= 0:
				# Player has enough or more tokens then cost of card to player
				cost[token_color] = token_cost
			else:
				# Card costs more tokens then player has
				cost[token_color] = player_owned_tokens
				gold_needed += token_cost - player_owned_tokens
				
	var gold_tokens_owned = get_value(player_state.tokens, TokenColor.GOLD)
	
	if gold_needed == 0:
		cost['can_purchase'] = true
	elif gold_tokens_owned >= gold_needed:
		cost[Constants.token_colors[0]] = gold_needed
		cost['can_purchase'] = true
	elif gold_tokens_owned < gold_needed:
		cost['can_purchase'] = false
	
	return cost
		
	
func get_value(dictionary, key):
	if key in dictionary:
		return dictionary[key]
	else:
		return 0

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
		if num_tokens_owned > 0:
			child_node.get_node("tokens").get_node("small").texture = load("res://assets/card/small_" + str(num_tokens_owned) + ".png")
		
		var num_cards_owned = 0
		if i > 0:
			if token_colors[i] in cards:
				num_cards_owned = len(cards[token_colors[i]])
			child_node.get_node("big").visible = num_cards_owned > 0
			if num_cards_owned > 0:
				child_node.get_node("big").texture = load("res://assets/card/big_" + str(num_cards_owned) + ".png")
		
		child_node.visible = num_tokens_owned > 0 or num_cards_owned > 0
		
		i += 1

func update_player_stats():
	Constants.delete_children(player_stats_hud)
	var y_offset = 300
	var off_set = 18
	var i = 0
	var turn_order = game_state.turn_order
	var map = {}
	for p in room.players:
		map[p.id] = p
	for p_json in turn_order:
		var p_id = p_json["id"]
		var player: Player = map[p_id]
		if p_id != host_player.id:
			var player_stats: PlayerStats = PlayerStatsScene.instance()
			player_stats_hud.add_child(player_stats)
			player_stats.position.y = (i * y_offset) + off_set
			var player_state: PlayerState = game_state.player_states[player.id]
			player_stats.init(player.id, player_state)
		i += 1
	

func _on_EndTurn_pressed():
	var selected_noble = null
	var noble_index = -1
	for i in range(len(selection)):
		if selection[i] is Noble:
			noble_index = i
			break
	if noble_index != -1:
		selected_noble = selection[noble_index]
		selection.remove(noble_index)
	# room_id, player_id, game_state_id, end_turn_action, noble: Noble,
	# card: Card, reserved_card: Card, tokens_returned: Array, tokens_bought: Array
	if current_game_state == GameState.CARD_SELECTED:
		end_turn_button.visible = false
		discard_button.visible = false
		http_client.end_turn_request.end_turn(
			room.id,
			host_player.id,
			game_state.id,
			EndTurnAction.BuyingCard,
			selected_noble,
			selection[0],
			null,
			selection[0].get_tokens_returned(),
			[]
		)
	elif current_game_state == GameState.RESERVED_CARD_SELECTED:
		end_turn_button.visible = false
		discard_button.visible = false
		http_client.end_turn_request.end_turn(
			room.id,
			host_player.id,
			game_state.id,
			EndTurnAction.BuyingReservedCard,
			selected_noble,
			selection[0],
			null,
			selection[0].get_tokens_returned(),
			[]
		)
	elif current_game_state == GameState.GOLD_TOKEN_SELECTED:
		end_turn_button.visible = false
		discard_button.visible = false
		if len(selection) == 2:
			http_client.end_turn_request.end_turn(
				room.id,
				host_player.id,
				game_state.id,
				EndTurnAction.BuyingGoldToken,
				selected_noble,
				null,
				selection[1],
				[],
				[selection[0]]
			)
	elif current_game_state == GameState.TOKENS_SELECTED:
		end_turn_button.visible = false
		discard_button.visible = false
		http_client.end_turn_request.end_turn(
			room.id,
			host_player.id,
			game_state.id,
			EndTurnAction.Buying3DifferentTokens,
			selected_noble,
			null,
			null,
			[],
			selection
		)


func _on_Discard_pressed():
	if current_game_state == GameState.MY_TURN:
		var player_states = game_state.player_states
		var player_state: PlayerState = player_states[host_player.id]
		if player_state.get_token_count() >= 8:
			discard_button.visible = false
			end_turn_button.visible = false
			http_client.end_turn_request.end_turn(
				room.id,
				host_player.id,
				game_state.id,
				EndTurnAction.DiscardTokens,
				null,
				null,
				null,
				[],
				[]
			)


func _on_Rules_pressed():
	rules_scene.visible = true
