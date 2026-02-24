extends Panel

func _ready():
	$PasswordAdd.hide()
	
	get_parent().get_parent().visibility_changed.connect(_on_visibility_changed)
	
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
					desktop.on_app_password_reset("Steam")
		)

func _on_visibility_changed():
	if get_parent().get_parent().visible:
		_reset_state()

func _reset_state():
	$PasswordAsk.show()
	$PasswordAdd.hide()
	if has_node("PasswordAdd/Panel/LineEdit"):
		$PasswordAdd/Panel/LineEdit.text = ""
