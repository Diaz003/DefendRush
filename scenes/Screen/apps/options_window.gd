extends "res://scenes/Screen/templates/template.gd"

@onready var cpu_bar = $Panel/WindowContent/VBoxContainer/CPUContainer/CPUBar
@onready var ram_bar = $Panel/WindowContent/VBoxContainer/RAMContainer/RAMBar

@onready var v_box_container = $Panel/WindowContent/VBoxContainer
@onready var permissions_container = $Panel/WindowContent/PermissionsContainer
@onready var antivirus_check = $Panel/WindowContent/PermissionsContainer/AntivirusPerms/AntivirusCheck

var update_timer: float = 0.0
var bar_style: StyleBoxFlat
var bg_style: StyleBoxFlat

var target_cpu: float = 15.0
var target_ram: float = 35.0

func _ready() -> void:
	bar_style = StyleBoxFlat.new()
	bar_style.bg_color = Color(0.2, 0.8, 0.2) # Green
	bar_style.border_width_bottom = 2
	bar_style.border_color = Color(0,0,0)

	bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1)

	cpu_bar.add_theme_stylebox_override("fill", bar_style)
	ram_bar.add_theme_stylebox_override("fill", bar_style)
	cpu_bar.add_theme_stylebox_override("background", bg_style)
	ram_bar.add_theme_stylebox_override("background", bg_style)

	
	$Panel/WindowContent/VBoxContainer/PermissionsButton.pressed.connect(func():
		v_box_container.hide()
		permissions_container.show()
	)
	
	$Panel/WindowContent/PermissionsContainer/TitleBox/BackButton.pressed.connect(func():
		permissions_container.hide()
		v_box_container.show()
	)
	
	antivirus_check.toggled.connect(_on_antivirus_toggled)
	_update_checkbox_text()

func _process(delta: float) -> void:
	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = 0.3
		_evaluate_system_status()
		
	# Smoothly animate the bars frame-by-frame
	cpu_bar.value = lerp(cpu_bar.value, target_cpu, delta * 8.0)
	ram_bar.value = lerp(ram_bar.value, target_ram, delta * 8.0)

func _evaluate_system_status() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	var has_malware = false
	var is_high_load = false
	
	if screen_node:
		if "active_malware" in screen_node:
			has_malware = screen_node.active_malware > 0
		if "is_scanner_active" in screen_node:
			is_high_load = screen_node.is_scanner_active or screen_node.is_anti_ransomware_active
		if "system_permissions_revoked" in screen_node:
			antivirus_check.set_pressed_no_signal(screen_node.system_permissions_revoked)
			_update_checkbox_text()
			
	if has_malware or is_high_load:
		target_cpu = randf_range(85.0, 100.0)
		target_ram = randf_range(80.0, 98.0)
		bar_style.bg_color = Color(1.0, 0.0, 0.0) # Bright Red
	else:
		target_cpu = randf_range(5.0, 25.0)
		target_ram = randf_range(30.0, 45.0)
		bar_style.bg_color = Color(0.2, 0.8, 0.2) # Green

func _on_antivirus_toggled(toggled_on: bool) -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node and "system_permissions_revoked" in screen_node:
		screen_node.system_permissions_revoked = toggled_on
	_update_checkbox_text()

func _update_checkbox_text() -> void:
	if antivirus_check.button_pressed:
		antivirus_check.text = "Status: ON (Protected)"
		antivirus_check.add_theme_color_override("font_color", Color(0, 0.7, 0))
	else:
		antivirus_check.text = "Status: OFF (Vulnerable)"
		antivirus_check.add_theme_color_override("font_color", Color(0.8, 0, 0))
