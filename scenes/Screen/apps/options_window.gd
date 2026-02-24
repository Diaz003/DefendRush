extends Control

@onready var cpu_bar = $Panel/WindowContent/VBoxContainer/CPUContainer/CPUBar
@onready var ram_bar = $Panel/WindowContent/VBoxContainer/RAMContainer/RAMBar

@onready var v_box_container = $Panel/WindowContent/VBoxContainer
@onready var permissions_container = $Panel/WindowContent/PermissionsContainer
@onready var antivirus_check = $Panel/WindowContent/PermissionsContainer/AntivirusPerms/AntivirusCheck

var update_timer: float = 0.0

func _ready() -> void:
	$Panel/WindowContent/VBoxContainer/QuitButton.pressed.connect(func(): get_tree().quit())
	
	$Panel/WindowContent/VBoxContainer/PermissionsButton.pressed.connect(func():
		v_box_container.hide()
		permissions_container.show()
	)
	
	$Panel/WindowContent/PermissionsContainer/TitleBox/BackButton.pressed.connect(func():
		permissions_container.hide()
		v_box_container.show()
	)
	
	antivirus_check.toggled.connect(_on_antivirus_toggled)

func _process(delta: float) -> void:
	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = 1.0 # Update every 1 second
		_update_status_bars()

func _update_status_bars() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	var has_malware = false
	var is_high_load = false
	
	if screen_node:
		if "active_malware" in screen_node:
			has_malware = screen_node.active_malware > 0
		if "is_scanner_active" in screen_node:
			is_high_load = screen_node.is_scanner_active or screen_node.is_anti_ransomware_active
		if "system_permissions_revoked" in screen_node:
			antivirus_check.button_pressed = screen_node.system_permissions_revoked
		
	if has_malware or is_high_load:
		# High usage erratic values
		cpu_bar.value = randf_range(85.0, 100.0)
		ram_bar.value = randf_range(80.0, 98.0)
		cpu_bar.modulate = Color(1, 0, 0) # Red color for warning
		ram_bar.modulate = Color(1, 0, 0)
	else:
		# Normal usage erratic values
		cpu_bar.value = randf_range(5.0, 25.0)
		ram_bar.value = randf_range(30.0, 45.0)
		cpu_bar.modulate = Color(1, 1, 1) # Normal color

func _on_antivirus_toggled(toggled_on: bool) -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node and "system_permissions_revoked" in screen_node:
		screen_node.system_permissions_revoked = toggled_on

func _on_close_button_pressed() -> void:
	hide()
