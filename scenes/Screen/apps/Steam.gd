extends Panel

func _ready():
	$PasswordAdd.hide()
	
	$PasswordAsk/Button.pressed.connect(func():
		$PasswordAsk.hide()
		$PasswordAdd.show()
	)
