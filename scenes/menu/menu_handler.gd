class_name MenuHandler extends Reference

#MENU_LEVEL.MAIN is index 1 not zero so keep that in mind if you change to an array


enum MENU_LEVEL {
		NONE,
		MAIN,
		START,
		JOIN,
		OPTIONS
	}


static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
	
func load_board(game_state: GameState, room: RoomDTO, host_player: Player):
	# Remove the current level
	var root = Constants.root

	# Add the next level
	var board_scene = load("res://scenes/board/Board.tscn")
	var board: Board = board_scene.instance()
	board.init(room, game_state, host_player)
	
	
	delete_children(root)
	root.add_child(board)
	
func load_menu(new_menu, current_scene):
	call_deferred("_deferred_load_menu", new_menu, current_scene)


func _deferred_load_menu(new_menu, current_scene):
	#replace the current menus instance with the new ones
	# current_menu = menus[menulevel]

	var container = current_scene.find_node("menu", false, false)
	if not container:
		var menunode = Node.new()
		menunode.set_name("menu")
		current_scene.add_child(menunode)
		container = menunode
	#clear the current menu item/s
	for location in container.get_children():
		container.remove_child(location)
	#add our selected menu
	container.add_child(new_menu)
