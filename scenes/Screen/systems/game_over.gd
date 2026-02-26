extends Control

func set_cause(cause: String) -> void:
	if has_node("VBoxContainer/CauseLabel"):
		if cause != "":
			$VBoxContainer/CauseLabel.text = cause
		else:
			$VBoxContainer/CauseLabel.text = "System failure."

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	
func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
