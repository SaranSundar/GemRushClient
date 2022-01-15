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


