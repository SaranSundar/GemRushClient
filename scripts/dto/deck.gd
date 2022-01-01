class_name Deck extends Reference

var tiered_cards: Dictionary# [Tier, List[Card]]
var noble_cards: Array#List[Noble]
var bank: Dictionary# [TokenColor, int]
# Cards drawn from tiered_cards end up in board
var board: Dictionary# [Tier, List[Card]] = field(default_factory=lambda: {})

func _init(json):
	tiered_cards = json['tiered_cards']
	noble_cards = json['noble_cards']
	bank = json['bank']
	board = json['board']
