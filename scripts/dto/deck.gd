class_name Deck extends Reference

var tiered_cards: Dictionary# [Tier, List[Card]]
var noble_cards: Array#List[Noble]
var bank: Dictionary# [TokenColor, int]
# Cards drawn from tiered_cards end up in board
var board: Dictionary# [Tier, List[Card]] = field(default_factory=lambda: {})

func _init(json):
	bank = json['bank']
	init_board_cards(json['board'])
	init_tiered_cards(json['tiered_cards'])
	init_noble_cards(json['noble_cards'])

func init_board_cards(json_board_cards):
	board = {}
	for key in json_board_cards:
		board[key] = []
		for card_json in json_board_cards[key]:
			var card = CardDTO.new()
			card.init_from_json(card_json)
			board[key].append(card)

func init_tiered_cards(json_tiered_cards):
	tiered_cards = {}
	for key in json_tiered_cards:
		tiered_cards[key] = []
		for card_json in json_tiered_cards[key]:
			var card = CardDTO.new()
			card.init_from_json(card_json)
			tiered_cards[key].append(card)

func init_noble_cards(json_noble_cards):
	noble_cards = []
	for noble_json in json_noble_cards:
		var noble = Noble.new()
		noble.init_from_json(noble_json)
		noble_cards.append(noble)
		
