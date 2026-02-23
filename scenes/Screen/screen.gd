extends Control

var time_left_seconds: float = 10 * 60.0  
var last_update_second: int = 0

var score: int = 0
var file_spawn_timer: float = 3.0 * 60.0
var mail_spawn_timer: float = 2.0 * 60.0
var game_over_timer: float = 0.0
var active_malware: int = 0
var apps_needing_password_reset: Array[String] = []
var antivirus_permissions_granted: bool = false

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
	$CanvasLayer/Guide.hide()
	
	set_process(false)
	var power_on = power_on_scene.instantiate()
	add_child(power_on)
	power_on.power_on_completed.connect(func(): set_process(true))
	
	logs_window = $CanvasLayer.get_node_or_null("LogsWindow")
	
	$ExplorerButton.pressed.connect(func(): $CanvasLayer/BrowserWindows.show())
	$MailButton.pressed.connect(func(): $CanvasLayer/MailWindow.show())
	$PayPalButton.pressed.connect(func(): $CanvasLayer/BankWindow.show())
	$SteamButton.pressed.connect(func(): $CanvasLayer/SteamWindow.show())
	$FileButton.pressed.connect(func(): $CanvasLayer/FileManager.show())
	$SecureButton.pressed.connect(func(): $CanvasLayer/Antivirus.show())
	$ConfigButton.pressed.connect(func(): $CanvasLayer/OptionsWindow.show())
	$Toolbar/utils/Logs.pressed.connect(func(): 
		if logs_window: logs_window.show()
	)
	guide_button.pressed.connect(func(): guide_window.show())

	_update_time_label()


func _process(delta: float) -> void:
	var is_browsing: bool = false
	if $CanvasLayer/BrowserWindows.visible:
		var nav_node = $CanvasLayer/BrowserWindows/Panel/WindowContent.get_node_or_null("Navigating")
		if nav_node and nav_node.visible:
			is_browsing = true

	if time_left_seconds > 0.0:
		time_left_seconds -= delta

		var current_second: int = int(time_left_seconds)
		if current_second != last_update_second:
			last_update_second = current_second
			_update_time_label()

		if time_left_seconds <= 0.0:
			time_left_seconds = 0.0
			_update_time_label()
			_on_game_end()

	if is_browsing:				
		if file_spawn_timer > 0.0:
			file_spawn_timer -= delta
			if file_spawn_timer <= 0.0:
				file_spawn_timer = 3.0 * 60.0
				_spawn_file()
				
		if mail_spawn_timer > 0.0:
			mail_spawn_timer -= delta
			if mail_spawn_timer <= 0.0:
				mail_spawn_timer = 2.0 * 60.0
				_spawn_mail()
				
	if game_over_timer > 0.0:
		game_over_timer -= delta
		if game_over_timer <= 0.0:
			_on_game_end()

func show_toast(message: String) -> void:
	if $CanvasLayer.has_node("NotificationToast"):
		$CanvasLayer/NotificationToast.show_toast(message)

func add_log(message: String, is_warning: bool = false) -> void:
	if logs_window and logs_window.has_method("add_log"):
		logs_window.add_log(message, is_warning)

func on_app_password_reset(app_name: String) -> void:
	if apps_needing_password_reset.has(app_name):
		apps_needing_password_reset.erase(app_name)
		add_log("Contraseña de " + app_name + " restablecida.", false)
		if apps_needing_password_reset.is_empty():
			show_toast("¡Todas las contraseñas restablecidas! Estás a salvo.")
			add_log("Sistema asegurado: Todas las contraseñas cambiadas.", false)

func _spawn_file() -> void:
	var names = ["Document.txt", "Audio.wav", "Video.mp4", "Image.jpg"]
	var selected_name = names[randi() % names.size()]
	
	var is_exe = (randi() % 5) == 4 # 1 in 5 chance (0-4)
	if is_exe:
		selected_name += ".exe"
		
	var new_file = file_item_scene.instantiate()
	var container = $CanvasLayer/FileManager/Panel/WindowContent/ScrollContainer/VBoxContainer
	container.add_child(new_file)
	new_file.setup(selected_name, is_exe)
	
	if is_exe:
		new_file.file_executed.connect(_on_file_executed)
		show_toast("Se han detectado amenazas en el sistema (archivo malicioso)")
		add_log("Archivo malicioso descargado: " + selected_name, true)
	else:
		add_log("Archivo descargado: " + selected_name, false)

func _on_file_executed(consequence: int) -> void:
	if consequence == 1:
		score -= 1000
		active_malware += 1
		show_toast("El sistema se ha ralentizado (Malware).")
		add_log("INFECCIÓN: Malware activo. Rendimiento del sistema degradado.", true)
	elif consequence == 2:
		if game_over_timer <= 0.0 or game_over_timer > 5.0 * 60.0:
			game_over_timer = 5.0 * 60.0
			show_toast("¡PELIGRO! Troyano detectado. Destrucción del sistema inminente.")
			add_log("ALERTA CRÍTICA: Troyano ejecutado. 5 minutos para el fallo total.", true)
	elif consequence == 3:
		if game_over_timer <= 0.0 or game_over_timer > 5.0 * 60.0:
			game_over_timer = 5.0 * 60.0
			show_toast("¡PELIGRO! Ransomware detectado. Archivos encriptándose...")
			add_log("ALERTA CRÍTICA: Ransomware ejecutado. Usa el Antivirus para detenerlo.", true)

func _spawn_mail() -> void:
	var type = randi() % 6 + 1
	var is_malicious = type >= 5
	
	var subjects = ["Meeting Notes", "Weekly Update", "Hello!", "Project Status", "URGENT: Bank Security Alert", "Congratulations!"]
	var bodies = ["Please review the attached notes.", "Here is the summary.", "Just saying hi.", "We are on track.", "Your account has been restricted. Click Verify to restore access.", "You have won 10,000 Euros! Click here to claim."]
	
	var sub = subjects[type - 1]
	var bod = bodies[type - 1]
		
	var new_mail = mail_item_scene.instantiate()
	var container = $CanvasLayer/MailWindow/Panel/WindowContent/ScrollContainer/VBoxContainer
	container.add_child(new_mail)
	new_mail.setup(sub, bod, is_malicious, type)
	new_mail.mail_handled.connect(_on_mail_handled)
	
	if is_malicious:
		show_toast("Se han detectado amenazas en el sistema (correos)")
		add_log("Correo sospechoso recibido: " + sub, true)
	else:
		add_log("Nuevo correo: " + sub, false)

func _on_mail_handled(is_malicious: bool, accept: bool) -> void:
	if is_malicious:
		if accept:
			score -= 1500
			apps_needing_password_reset = ["Browser", "Bank", "Steam", "Mail"]
			show_toast("¡Han robado tus contraseñas! Cambia tus contraseñas en todas las apps para estar seguro.")
			add_log("ALERTA CRÍTICA: Contraseñas comprometidas por phishing.", true)
			
			$CanvasLayer/BrowserWindows.show()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/Navigating.hide()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/BrowserAsk.hide()
			if $CanvasLayer/BrowserWindows/Panel/WindowContent.has_node("Separator"):
				$CanvasLayer/BrowserWindows/Panel/WindowContent/Separator.hide()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/PasswordAsk.hide()
			$CanvasLayer/BrowserWindows/Panel/WindowContent/PasswordAdd.show()
			
			# Mostrar ventanas para las demas apps que necesitan cambio y prepararlas
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
				if $CanvasLayer/MailWindow/Panel/WindowContent.has_node("ScrollContainer"):
					$CanvasLayer/MailWindow/Panel/WindowContent/ScrollContainer.hide()
				$CanvasLayer/MailWindow/Panel/WindowContent/PasswordAdd.hide()
				$CanvasLayer/MailWindow/Panel/WindowContent/PasswordAsk.show()
		else:
			score += 500
			add_log("Phishing evadido exitosamente.", false)
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
