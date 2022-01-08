class_name CardDTO extends Reference


var points: int
var tier: Tier
var color: CardColor
var cost: Dictionary


func init_from_json(data):
	points = data['points']
	tier = data['tier']
	color = data['color']
	cost = data['cost']
