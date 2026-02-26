extends Control

func set_score(final_score: int) -> void:
	if has_node("VBoxContainer/ScoreLabel"):
		$VBoxContainer/ScoreLabel.text = "Final Score: " + str(final_score)
	if has_node("VBoxContainer/RatingLabel"):
		$VBoxContainer/RatingLabel.text = _get_rating(final_score)

func _get_rating(s: int) -> String:
	if s >= 10000:
		return "Rating: PLATINUM"
	elif s >= 5000:
		return "Rating: GOLD"
	elif s >= 2000:
		return "Rating: SILVER"
	else:
		return "Rating: BRONZE"

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	
func _on_menu_pressed() -> void:
	$AudioStreamPlayer2D.play()
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
