class_name CardDTO extends Reference


var points: int
var tier: String#Tier
var color: String#CardColor
var cost: Dictionary# Dict[TokenColor, int]

var player_cost: Dictionary

var data

func get_tokens_returned():
	var tokens_returned = []
	for token in player_cost:
		if token == "can_purchase":
			continue
		var num_tokens = player_cost[token]
		for i in range(num_tokens):
			tokens_returned.append(token)
	return tokens_returned

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
