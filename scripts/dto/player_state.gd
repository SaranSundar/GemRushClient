class_name PlayerState extends Reference

var cards: Dictionary
var tokens: Dictionary
var reserved_cards: Array
var nobles: Array

func init_from_json(data):
	cards = data['cards']
	tokens = data['tokens']
	reserved_cards = data['reserved_cards']
	nobles = data['nobles']
