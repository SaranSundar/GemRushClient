class_name RecentMove extends Control

signal clicked_hide_recent_move()

var tokens: VBoxContainer
var card: Card


func init_from_json(player_state: PlayerState):
	tokens = $Panel/VBoxContainer
	card = $Panel/Card
	
	print("Last Move")
	print(player_state.last_move)
	var last_move = player_state.last_move['payload']
	var tokens_bought = last_move['tokens_bought']
	var reserved_card = last_move['reserved_card']
	var bought_card = last_move['bought_card']
	var nobles = player_state.nobles
	
	Constants.delete_children(tokens)
	var i = 0.5
	for token_color in tokens_bought:
		var sprite = Sprite.new()
		sprite.texture = load("res://assets/card/" + token_color.to_lower() + "_token.png")
		sprite.position.y = i * 100
		sprite.position.x = 50
		tokens.add_child(sprite)
		i += 1
	
	card.visible = false
		
	if reserved_card:
		card.visible = true
		var card_dto = CardDTO.new()
		card_dto.init_from_json(reserved_card)
		card.init_from_json(card_dto)
		card.update_card_shader({'can_purchase': false})
	
	if bought_card:
		card.visible = true
		var card_dto = CardDTO.new()
		card_dto.init_from_json(bought_card)
		card.init_from_json(card_dto)
		card.update_card_shader({'can_purchase': false})


func _on_TextureButton_pressed():
	emit_signal("clicked_hide_recent_move")
