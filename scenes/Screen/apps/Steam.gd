extends Panel

# Game cooldowns (seconds remaining, 0 = ready)
var game_cooldowns: Array[float] = [0.0, 0.0, 0.0]
var game_rewards: Array[int] = [300, 500, 200]
var game_cooldown_times: Array[float] = [30.0, 60.0, 20.0]
var game_names: Array[String] = ["CyberDefender", "HackSimulator", "DataMiner"]
var point_timer: float = 0.0

func _ready():
	$PasswordAdd.hide()
	if has_node("AppContent"):
		$AppContent.hide()
	
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
				_show_app()
				var desktop = get_tree().root.get_node_or_null("Desktop")
				if desktop and desktop.has_method("on_app_password_reset"):
					desktop.on_app_password_reset("Steam")
		)
	
	# Connect game buttons
	if has_node("AppContent/Game1Button"):
		$AppContent/Game1Button.pressed.connect(func(): _play_game(0))
	if has_node("AppContent/Game2Button"):
		$AppContent/Game2Button.pressed.connect(func(): _play_game(1))
	if has_node("AppContent/Game3Button"):
		$AppContent/Game3Button.pressed.connect(func(): _play_game(2))

func _show_app() -> void:
	$PasswordAsk.hide()
	$PasswordAdd.hide()
	if has_node("AppContent"):
		$AppContent.show()
		_update_ui()

func _process(delta: float) -> void:
	var win = get_parent().get_parent()
	if not win.visible:
		return
	
	# Passive income while Steam is open and in app mode
	if has_node("AppContent") and $AppContent.visible:
		point_timer += delta
		if point_timer >= 1.0:
			point_timer -= 1.0
			var desktop = get_tree().root.get_node_or_null("Desktop")
			if desktop:
				desktop.score += 2
	
	# Tick down cooldowns
	var any_changed = false
	for i in range(game_cooldowns.size()):
		if game_cooldowns[i] > 0.0:
			game_cooldowns[i] -= delta
			if game_cooldowns[i] < 0.0:
				game_cooldowns[i] = 0.0
			any_changed = true
	
	if any_changed and has_node("AppContent") and $AppContent.visible:
		_update_ui()

func _play_game(index: int) -> void:
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if not desktop: return
	
	if game_cooldowns[index] > 0.0:
		desktop.show_toast(game_names[index] + " is on cooldown! Wait " + str(int(game_cooldowns[index])) + "s.")
		return
	
	# Award points and start cooldown
	var reward = game_rewards[index]
	desktop.score += reward
	game_cooldowns[index] = game_cooldown_times[index]
	desktop.show_toast("Played " + game_names[index] + "! +" + str(reward) + " pts!")
	desktop.add_log("STEAM: Played " + game_names[index] + ". +" + str(reward) + " score.", false)
	_update_status("Playing " + game_names[index] + "...")
	_update_ui()

func _update_ui() -> void:
	var buttons = ["Game1Button", "Game2Button", "Game3Button"]
	for i in range(3):
		var btn_name = "AppContent/" + buttons[i]
		if has_node(btn_name):
			var btn = get_node(btn_name)
			if game_cooldowns[i] > 0.0:
				btn.text = game_names[i] + " (cooldown " + str(int(game_cooldowns[i])) + "s)"
				btn.disabled = true
			else:
				btn.text = "Play " + game_names[i] + " (+" + str(game_rewards[i]) + " pts)"
				btn.disabled = false

func _update_status(msg: String) -> void:
	if has_node("AppContent/StatusLabel"):
		$AppContent/StatusLabel.text = msg

func _on_visibility_changed():
	if get_parent().get_parent().visible:
		point_timer = 0.0
		_reset_state()

func _reset_state():
	$PasswordAdd.hide()
	if has_node("PasswordAdd/Panel/LineEdit"):
		$PasswordAdd/Panel/LineEdit.text = ""
	
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if desktop and "apps_needing_password_reset" in desktop and desktop.apps_needing_password_reset.has("Steam"):
		$PasswordAsk.hide()
		if has_node("AppContent"):
			$AppContent.hide()
		$PasswordAdd.show()
	else:
		_show_app()
