extends Panel

func _ready():
	$PasswordAdd.hide()
	$Navegating.hide()
	
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
	
