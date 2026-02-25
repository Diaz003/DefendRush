extends Panel

var point_timer: float = 0.0

func _ready():
	if has_node("PasswordAdd"):
		$PasswordAdd.hide()
	
	if has_node("PasswordAsk/Button"):
		$PasswordAsk/Button.pressed.connect(func():
			$PasswordAsk.hide()
			$PasswordAdd.show()
		)
	
	if has_node("PasswordAdd/Panel/LineEdit"):
		$PasswordAdd/Panel/LineEdit.text_submitted.connect(func(new_text):
			if new_text.strip_edges().length() > 0:
				$PasswordAdd/Panel/LineEdit.text = ""
				$PasswordAdd.hide()
				if has_node("ScrollContainer"):
					$ScrollContainer.show()
				var desktop = get_tree().root.get_node_or_null("Desktop")
				if desktop and desktop.has_method("on_app_password_reset"):
					desktop.on_app_password_reset("Mail")
		)

func _process(delta: float) -> void:
	# Check if the MailWindow parent is visible
	var mail_window = get_parent()
	if not mail_window or not mail_window.visible:
		return
	# Don't earn points while password reset is showing
	if has_node("PasswordAdd") and $PasswordAdd.visible:
		return
	point_timer += delta
	if point_timer >= 1.0:
		point_timer -= 1.0
		var desktop = get_tree().root.get_node_or_null("Desktop")
		if desktop:
			desktop.score += 1
