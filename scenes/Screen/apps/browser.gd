extends Panel

func _ready():
	$PasswordAdd.hide()
	$Navigating.hide()
	
	owner.visibility_changed.connect(_on_window_visibility_changed)
	
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

func _on_window_visibility_changed() -> void:
	if owner.visible:
		var desktop = get_tree().root.get_node_or_null("Desktop")
		if desktop and "apps_needing_password_reset" in desktop and desktop.apps_needing_password_reset.has("Browser"):
			$Navigating.hide()
			$BrowserAsk.hide()
			$Separator.hide()
			$PasswordAsk.hide()
			$PasswordAdd.show()
		else:
			$PasswordAdd.hide()
			$PasswordAsk.show()
			$BrowserAsk.show()
			$Separator.show()
	
