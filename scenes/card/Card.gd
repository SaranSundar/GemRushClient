class_name Card extends Node2D


var card_dto: CardDTO

var base: Sprite
var gem: Sprite
var points: Sprite
var costs: Array

func init_from_json(cardDTO: CardDTO):
	card_dto = cardDTO
	base = $base
	gem = $gem
	points = $points
	costs = [$cost1_base, $cost2_base, $cost3_base, $cost4_base]
	update_graphics()

func update_graphics():
	base.texture = load("res://assets/card/" +  card_dto.color.to_lower() + "_card.png")
	gem.texture = load("res://assets/card/" +  card_dto.color.to_lower() + "_gem.png")
	points.texture = load("res://assets/card/big_" +  str(card_dto.points) + ".png")
	var keys = card_dto.cost.keys()
	var costs_with_values = []
	var card_circle_index = 0
	for i in range(len(keys)):
		if card_dto.cost[keys[i]] != 0:
			# Append the color and the value
			costs_with_values.append([keys[i], card_dto.cost[keys[i]]])
	var i = 0
	for cost_node in costs:
		if i < len(costs_with_values):
			cost_node.visible = true
			cost_node.texture = load("res://assets/card/" +  costs_with_values[i][0].to_lower() + "_circle.png")
			cost_node.get_node("cost").texture = load("res://assets/card/small_" +  str(costs_with_values[i][1]) + ".png")
		else:
			cost_node.visible = false
		
		i += 1
	
	
