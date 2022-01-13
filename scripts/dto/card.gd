class_name CardDTO extends Reference


var points: int
var tier: String#Tier
var color: String#CardColor
var cost: Dictionary# Dict[TokenColor, int]

var data

func get_as_json():
	return {
		"points": points,
		"tier": tier,
		"color": color,
		"cost": cost
	}

func init_from_json(data):
	self.data = data
	points = data['points']
	tier = data['tier']
	color = data['color']
	cost = data['cost']
