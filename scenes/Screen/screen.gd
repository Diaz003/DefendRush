extends Control

var time_left_seconds: float = 10 * 60.0  
var last_update_second: int = 0

var score: int = 0
var file_spawn_timer: float = 10.0
var mail_spawn_timer: float = 20.0
var game_over_timer: float = 0.0
var active_malware: int = 0
var apps_needing_password_reset: Array[String] = []

# Permissions and System State Variables
var antivirus_permissions_granted: bool = false
var system_permissions_revoked: bool = false
var is_scanner_active: bool = false
var is_anti_ransomware_active: bool = false
var has_active_ransomware: bool = false
var has_active_trojan: bool = false

var can_delete_files: bool = false

var current_file_spawn_interval: float = 10.0
var exe_spawn_chance_divisor: int = 5
var exe_score_penalty: int = 1000

var clip_npc: Node = null

@onready var file_item_scene = preload("res://scenes/Screen/systems/FileItem.tscn")
@onready var notification_toast_scene = preload("res://scenes/Screen/systems/NotificationToast.tscn")
@onready var mail_item_scene = preload("res://scenes/Screen/apps/mails.tscn")
@onready var power_on_scene = preload("res://scenes/Screen/systems/PowerOnSequence.tscn")

var logs_window: Node = null


@onready var time_label: Label = $Toolbar/utils/HourText/Text
@onready var guide_button := $Toolbar/utils/Guide
@onready var guide_window := $CanvasLayer/Guide

func _ready() -> void:
	$CanvasLayer/Antivirus.hide()
	$CanvasLayer/BankWindow.hide()
	$CanvasLayer/BrowserWindows.hide()
	$CanvasLayer/FileManager.hide()
	$CanvasLayer/SteamWindow.hide()
	$CanvasLayer/MailWindow.hide()
	$CanvasLayer/OptionsWindow.hide()
	$CanvasLayer/Guide.show()
	
	set_process(false)
	var power_on = power_on_scene.instantiate()
	add_child(power_on)
	power_on.power_on_completed.connect(func(): set_process(true))
	
	logs_window = $CanvasLayer.get_node_or_null("LogsWindow")
	
	$ExplorerButton.pressed.connect(func(): $CanvasLayer/BrowserWindows.show())
	$MailButton.pressed.connect(func(): $CanvasLayer/MailWindow.show())
	$PayPalButton.pressed.connect(func(): $CanvasLayer/BankWindow.show())
	$SteamButton.pressed.connect(func(): $CanvasLayer/SteamWindow.show())
	$BinButton.pressed.connect(func():
		var bin = $CanvasLayer.get_node_or_null("BinWindow")
		if bin: 
			bin.show()
			bin.move_to_front()
	)
	$FileButton.pressed.connect(func(): 
		if has_active_ransomware:
			show_toast("Error: Ransomware blocks access to system files.")
		else:
			$CanvasLayer/FileManager.show()
	)
	$SecureButton.pressed.connect(func(): $CanvasLayer/Antivirus.show())
	$ConfigButton.pressed.connect(func(): $CanvasLayer/OptionsWindow.show())
	$Toolbar/utils/Logs.pressed.connect(func(): 
		if logs_window: logs_window.show()
	)
	guide_button.pressed.connect(func(): guide_window.show())
	
	$Toolbar/utils/Sound.pressed.connect(func():
		var vol_popup = get_node_or_null("VolumePopup")
		if vol_popup:
			vol_popup.visible = !vol_popup.visible
	)
	var vol_slider = get_node_or_null("VolumePopup/VSlider")
	if vol_slider:
		vol_slider.value_changed.connect(func(value: float):
			AudioServer.set_bus_volume_db(0, value)
			AudioServer.set_bus_mute(0, value == vol_slider.min_value)
		)

	_update_time_label()
	_init_clip_npc()

func _init_clip_npc() -> void:
	# Placeholder structure for Clip NPC initialization later
	# clip_npc = $CanvasLayer/ClipNPC
	pass


func _process(delta: float) -> void:
	if time_left_seconds > 0.0:
		time_left_seconds -= delta

		var current_second: int = int(time_left_seconds)
		if current_second != last_update_second:
			last_update_second = current_second
			
			# Urgent Password Robbery Mechanic (Point Drain)
			if apps_needing_password_reset.size() > 0:
				score -= 3 * apps_needing_password_reset.size()
				time_label.add_theme_color_override("font_color", Color(1, 0, 0)) # Red text warning
			else:
				time_label.remove_theme_color_override("font_color")
				
			_update_time_label()
			if active_malware > 0:
				score -= 10 * active_malware

		if time_left_seconds <= 0.0:
			time_left_seconds = 0.0
			_update_time_label()
			_on_game_end()
			
		if score <= 0 and active_malware > 0:
			score = 0
			_on_game_end()
			
	if file_spawn_timer > 0.0:
		file_spawn_timer -= delta
		if file_spawn_timer <= 0.0:
			file_spawn_timer = current_file_spawn_interval
			_spawn_file()
			
	if mail_spawn_timer > 0.0:
		mail_spawn_timer -= delta
		if mail_spawn_timer <= 0.0:
			mail_spawn_timer = 20.0
			_spawn_mail()
				
	if game_over_timer > 0.0:
		game_over_timer -= delta
		if game_over_timer <= 0.0:
			_on_game_end()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var vol_popup = get_node_or_null("VolumePopup")
		if vol_popup and vol_popup.visible:
			var popup_rect = vol_popup.get_global_rect()
			var sound_btn = $Toolbar/utils/Sound
			var btn_rect = sound_btn.get_global_rect()
			
			if not popup_rect.has_point(event.global_position) and not btn_rect.has_point(event.global_position):
				vol_popup.hide()

func show_toast(message: String) -> void:
	if $CanvasLayer.has_node("NotificationToast"):
		$CanvasLayer/NotificationToast.show_toast(message)

func add_log(message: String, is_warning: bool = false) -> void:
	if logs_window and logs_window.has_method("add_log"):
		logs_window.add_log(message, is_warning)

func on_app_password_reset(app_name: String) -> void:
	if apps_needing_password_reset.has(app_name):
		apps_needing_password_reset.erase(app_name)
		add_log("Password for " + app_name + " reset.", false)
		if apps_needing_password_reset.is_empty():
			show_toast("All passwords reset! You are safe.")
			add_log("System secured: All passwords changed.", false)

func _spawn_file(force_exe: bool = false) -> void:
	var names = ["Document.txt", "Audio.wav", "Video.mp4", "Image.jpg"]
	var selected_name = names[randi() % names.size()]
	
	var is_exe = force_exe or (randi() % exe_spawn_chance_divisor) == (exe_spawn_chance_divisor - 1)
	if is_exe:
		selected_name += ".exe"
		
	var new_file = file_item_scene.instantiate()
	var container = $CanvasLayer/FileManager/Panel/WindowContent/ScrollContainer/VBoxContainer
	new_file.setup(selected_name, is_exe)
	
	if is_exe:
		if new_file.consequence_type == 3 and is_anti_ransomware_active:
			new_file.queue_free()
			show_toast("Anti-Ransomware auto-deleted a Ransomware file before execution.")
			add_log("ACTIVE PROTECTION: Ransomware downloaded and instantly deleted.", false)
			return
			
	container.add_child(new_file)
	
	if is_exe:
		new_file.file_executed.connect(_on_file_executed)
		if is_scanner_active:
			show_toast("Scanner detected potential threats in the system.")
			add_log("SCANNER: Suspicious file downloaded: " + selected_name, true)
	else:
		if is_scanner_active:
			add_log("SCANNER: Downloaded file analyzed (Safe): " + selected_name, false)
		else:
			add_log("System: File downloaded: " + selected_name, false)

func _on_file_executed(consequence: int) -> void:
	if consequence == 1:
		score -= exe_score_penalty
		active_malware += 1
		show_toast("The system has slowed down (Malware).")
		add_log("INFECTION: Active malware. Degraded system performance.", true)
	elif consequence == 2:
		has_active_trojan = true
		if game_over_timer <= 0.0 or game_over_timer > 90.0:
			game_over_timer = 90.0
		show_toast("DANGER! Trojan detected. System destruction in 1 Minute and 30 Seconds.")
		add_log("CRITICAL ALERT: Trojan executed. 1:30 to total failure.", true)
	elif consequence == 3:
		if is_anti_ransomware_active:
			show_toast("Anti-Ransomware tool blocked a critical infection.")
			add_log("ACTIVE PROTECTION: Ransomware attack prevented.", false)
		else:
			has_active_ransomware = true
			if game_over_timer <= 0.0 or game_over_timer > 5.0 * 60.0:
				game_over_timer = 5.0 * 60.0
			show_toast("DANGER! Ransomware detected. Administrator permissions hijacked.")
			add_log("CRITICAL ALERT: Ransomware executed. Limits access and files.", true)

func _spawn_mail() -> void:
	var container = $CanvasLayer/MailWindow/InboxPanel/ScrollContainer/VBoxContainer
	if not container:
		return
	if container.get_child_count() >= 3:
		score -= 2000
		show_toast("You have ignored too many emails! Massive infection detected.")
		add_log("PENALTY: Too many unread emails. Multiple virus attack.", true)
		for i in range(3):
			_spawn_file(true)
			
	var type = randi() % 6 + 1
	var is_malicious = type >= 5
	
	var subjects = ["Meeting Notes", "Weekly Update", "Hello!", "Project Status", "URGENT: Bank Security Alert", "Congratulations!"]
	var bodies = ["Please review the attached notes.", "Here is the summary.", "Just saying hi.", "We are on track.", "Your account has been restricted. Click Verify to restore access.", "You have won 10,000 Euros! Click here to claim."]
	
	var sub = subjects[type - 1]
	var bod = bodies[type - 1]
		
	var new_mail = mail_item_scene.instantiate()
	container.add_child(new_mail)
	new_mail.setup(sub, bod, is_malicious, type)
	new_mail.mail_handled.connect(_on_mail_handled)
	
	if is_malicious:
		if is_scanner_active:
			show_toast("Scanner blocked a phishing attempt. Check your email.")
			add_log("SCANNER: Malicious email detected and analyzed: " + sub, true)
	else:
		if is_scanner_active:
			add_log("SCANNER: Email analyzed (Safe): " + sub, false)
		else:
			add_log("System: New email received: " + sub, false)

func _on_mail_handled(is_malicious: bool, accept: bool) -> void:
	if is_malicious:
		if accept:
			score -= 3000
			current_file_spawn_interval = 10.0
			exe_spawn_chance_divisor = 2
			exe_score_penalty = 2000
			apps_needing_password_reset = ["Browser", "Bank", "Steam", "Mail"]
			show_toast("Your passwords have been stolen! Change your passwords in all apps to be safe.")
			add_log("CRITICAL ALERT: Passwords compromised by phishing. Viruses will attack faster and stronger.", true)
			
			$CanvasLayer/BrowserWindows.show()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/Navigating.hide()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/BrowserAsk.hide()
			if $CanvasLayer/BrowserWindows/Panel/WindowContent.has_node("Separator"):
				$CanvasLayer/BrowserWindows/Panel/WindowContent/Separator.hide()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/PasswordAsk.hide()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/PasswordAdd.show()
			
			# Show windows for other apps that need changing and prepare them
			$CanvasLayer/BankWindow.show()
			if $CanvasLayer/BankWindow/Panel/WindowContent.has_node("PasswordAdd"):
				$CanvasLayer/BankWindow/Panel/WindowContent/PasswordAdd.hide()
				$CanvasLayer/BankWindow/Panel/WindowContent/PasswordAsk.show()
				
			$CanvasLayer/SteamWindow.show()
			if $CanvasLayer/SteamWindow/Panel/WindowContent.has_node("PasswordAdd"):
				$CanvasLayer/SteamWindow/Panel/WindowContent/PasswordAdd.hide()
				$CanvasLayer/SteamWindow/Panel/WindowContent/PasswordAsk.show()
				
			$CanvasLayer/MailWindow.show()
			if $CanvasLayer/MailWindow/Panel/WindowContent.has_node("PasswordAdd"):
				if $CanvasLayer/MailWindow.has_node("InboxPanel"):
					$CanvasLayer/MailWindow/InboxPanel.hide()
				$CanvasLayer/MailWindow/Panel/WindowContent/PasswordAdd.hide()
				$CanvasLayer/MailWindow/Panel/WindowContent/PasswordAsk.show()
		else:
			score += 500
			current_file_spawn_interval = 45.0
			exe_spawn_chance_divisor = 8
			exe_score_penalty = 1000
			show_toast("Phishing evaded. The system is calmer.")
			add_log("Phishing successfully evaded. Attacks will decrease temporarily.", false)
	else:
		if accept:
			score += 100
		else:
			score -= 200

func _update_time_label() -> void:
	var total: int = int(time_left_seconds)
	var minutes: int = int(total / 60.0)  
	var seconds: int = int(total % 60)
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_game_end() -> void:
	set_process(false)
	var game_over = $CanvasLayer.get_node_or_null("GameOver")
	if game_over:
		game_over.show()
		game_over.move_to_front()
