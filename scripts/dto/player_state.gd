class_name PlayerState extends Reference

var cards: Dictionary
var tokens: Dictionary
var reserved_cards: Array
var nobles: Array
var data

func get_total_points():
	var points = 0
	for card_color in cards:
		var cards_list = cards[card_color]
		for card in cards_list:
			points += int(card['points'])
	for noble in nobles:
		points += int(noble['points'])
	return points

func can_purchase_noble(noble_dto: Noble, card: CardDTO):
	for card_color in noble_dto.cost:
		if noble_dto.cost[card_color] == 0:
			continue
		var cards_owned = get_card_count(card_color)
		if card != null && card.color == card_color:
			cards_owned += 1
		if cards_owned < noble_dto.cost[card_color]:
			return false
	
	return true
		

func get_card_count(card_color):
	if card_color in cards:
		return len(cards[card_color])
	else:
		return 0
		

func init_from_json(data):
	self.data = data
	cards = data['cards']
	tokens = data['tokens']
	reserved_cards = data['reserved_cards']
	nobles = data['nobles']

func get_token_count():
	var num_tokens = 0
	for token in tokens:
		num_tokens += tokens[token]
	return num_tokens


