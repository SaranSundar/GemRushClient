class_name MenuHandler extends Reference

#MENU_LEVEL.MAIN is index 1 not zero so keep that in mind if you change to an array


enum MENU_LEVEL {
		NONE,
		MAIN,
		START,
		JOIN,
		OPTIONS
	}
	
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
