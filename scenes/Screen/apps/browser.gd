extends Panel

func _ready():
	$PasswordAdd.hide()
	$Navigating.hide()
	
	$PasswordAsk/Button.pressed.connect(func():
		$PasswordAsk.hide()
		$BrowserAsk.hide()
		$Separator.hide()
		$PasswordAdd.show()
	)
	
	$BrowserAsk/Button2.pressed.connect(func():
		$PasswordAsk.hide()
		$BrowserAsk.hide()
		$Separator.hide()
		$Navigating.show()
	)
	
	$PasswordAdd/Panel/LineEdit.text_submitted.connect(func(new_text):
		if new_text.strip_edges().length() > 0:
			$PasswordAdd/Panel/LineEdit.text = ""
			$PasswordAdd.hide()
			$Separator.show()
			$BrowserAsk.show()
			
			var desktop = get_tree().root.get_node_or_null("Desktop")
			if desktop and desktop.has_method("on_app_password_reset"):
				desktop.on_app_password_reset("Browser")
	)
	
