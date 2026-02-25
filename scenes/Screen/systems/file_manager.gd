extends "res://scenes/Screen/templates/template.gd"

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if not is_inside_tree():
			return
		if not visible:
			var tree = get_tree()
			if tree:
				var screen_node = tree.root.get_node_or_null("Desktop")
				if screen_node and "can_delete_files" in screen_node:
					screen_node.can_delete_files = false
