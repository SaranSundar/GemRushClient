class_name CardDTO extends Reference


var points: int
var tier: String#Tier
var color: String#CardColor
var cost: Dictionary# Dict[TokenColor, int]


func init_from_json(data):
	points = data['points']
	tier = data['tier']
	color = data['color']
	cost = data['cost']
