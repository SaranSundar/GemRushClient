class_name Noble extends Reference

var points: int
var cost: Dictionary

func init_from_json(data):
	points = data['points']
	cost = data['cost']
