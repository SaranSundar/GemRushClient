extends Node2D

var root: Node2D

var token_colors = [TokenColor.GOLD, TokenColor.BLACK, TokenColor.RED, TokenColor.GREEN,
	TokenColor.BLUE, TokenColor.WHITE]

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
