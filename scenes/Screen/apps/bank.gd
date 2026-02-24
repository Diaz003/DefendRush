extends Panel
func _ready():
	$PasswordAdd.hide()
	
	owner.visibility_changed.connect(_on_window_visibility_changed)
	
	$PasswordAsk/Button.pressed.connect(func():
		$PasswordAsk.hide()
		$PasswordAdd.show()
	)
	
	if has_node("PasswordAdd/Panel/LineEdit"):
		$PasswordAdd/Panel/LineEdit.text_submitted.connect(func(new_text):
			if new_text.strip_edges().length() > 0:
				$PasswordAdd/Panel/LineEdit.text = ""
				$PasswordAdd.hide()
				var desktop = get_tree().root.get_node_or_null("Desktop")
				if desktop and desktop.has_method("on_app_password_reset"):
					desktop.on_app_password_reset("Bank")
		)

func _on_window_visibility_changed() -> void:
	if owner.visible:
		var desktop = get_tree().root.get_node_or_null("Desktop")
		if desktop and "apps_needing_password_reset" in desktop and desktop.apps_needing_password_reset.has("Bank"):
			$PasswordAsk.hide()
			$PasswordAdd.show()
		else:
			$PasswordAdd/Panel/LineEdit.text = ""
			$PasswordAdd.hide()
			$PasswordAsk.show()
