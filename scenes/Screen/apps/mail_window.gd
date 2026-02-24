extends Panel

func _ready():
	if has_node("PasswordAdd"):
		$PasswordAdd.hide()
	
	if has_node("PasswordAsk/Button"):
		$PasswordAsk/Button.pressed.connect(func():
			$PasswordAsk.hide()
			$ScrollContainer.hide()
			$PasswordAdd.show()
		)
	
	if has_node("PasswordAdd/Panel/LineEdit"):
		$PasswordAdd/Panel/LineEdit.text_submitted.connect(func(new_text):
			if new_text.strip_edges().length() > 0:
				$PasswordAdd/Panel/LineEdit.text = ""
				$PasswordAdd.hide()
				$ScrollContainer.show()
				var desktop = get_tree().root.get_node_or_null("Desktop")
				if desktop and desktop.has_method("on_app_password_reset"):
					desktop.on_app_password_reset("Mail")
		)
