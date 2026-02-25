extends Control

func set_score(final_score: int) -> void:
	if has_node("VBoxContainer/ScoreLabel"):
		$VBoxContainer/ScoreLabel.text = "Final Score: " + str(final_score)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	
func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu/Menu.tscn")
