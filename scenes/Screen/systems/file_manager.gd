extends "res://scenes/Screen/templates/template.gd"

func hide() -> void:
    super.hide()
    var screen_node = get_tree().root.get_node_or_null("Desktop")
    if screen_node and "can_delete_files" in screen_node:
        screen_node.can_delete_files = false
