class_name NobleScene extends Node2D


var background: Sprite
var square1: Sprite
var square2: Sprite
var square3: Sprite
var points: Sprite

var noble_dto: Noble

signal clicked_card(card_data)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		emit_signal("clicked_card", noble_dto)

func init_from_json(noble: Noble):
	self.noble_dto = noble
	background = $background
	square1 = $square1
	square2 = $square2
	square3 = $square3
	var squares = [square1, square2, square3]
	points = $big
	var i = 0
	for color in noble.cost:
		if noble.cost[color] == 0:
			continue
		squares[i].texture = load("res://assets/card/" + color.to_lower() + "_square.png")
		squares[i].get_node("small").texture = load("res://assets/card/small_" + str(noble.cost[color]) + ".png")
		i += 1
	
	if i == 3:
		square3.visible = true
	else:
		square3.visible = false
	
