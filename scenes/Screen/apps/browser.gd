extends Panel

var vpn_active: bool = false
var vpn_point_timer: float = 0.0
var vpn_previous_spawn_interval: float = 10.0

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
		_on_vpn_connected()
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

func _on_vpn_connected() -> void:
	vpn_active = true
	vpn_point_timer = 0.0
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if desktop:
		vpn_previous_spawn_interval = desktop.current_file_spawn_interval
		desktop.current_file_spawn_interval = min(vpn_previous_spawn_interval, 6.0)
		desktop.show_toast("VPN Connected! Earning +2 pts/sec – but viruses are more aggressive!")
		desktop.add_log("VPN: Connection established. Passive income active. Threat level increased.", true)

func _process(delta: float) -> void:
	if not vpn_active:
		return
	if not $Navigating.visible:
		return
	
	vpn_point_timer += delta
	if vpn_point_timer >= 1.0:
		vpn_point_timer -= 1.0
		var desktop = get_tree().root.get_node_or_null("Desktop")
		if desktop:
			desktop.score += 2

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
			$PasswordAdd/Panel/LineEdit.text = ""
			$PasswordAdd.hide()
			$Navigating.hide()
			$PasswordAsk.show()
			$BrowserAsk.show()
			$Separator.show()
	else:
		if vpn_active:
			vpn_active = false
			var desktop = get_tree().root.get_node_or_null("Desktop")
			if desktop:
				desktop.current_file_spawn_interval = vpn_previous_spawn_interval
				desktop.show_toast("VPN Disconnected. Point income stopped. Virus activity normalised.")
				desktop.add_log("VPN: Connection closed. Spawn rate restored.", false)
