extends Panel

@onready var scanner_btn = $VBoxContainer/Button4
@onready var clean_malware_btn = $VBoxContainer2/Button3
@onready var anti_ransomware_btn = $VBoxContainer2/Button4
@onready var analyze_file_btn = $VBoxContainer/Button3
@onready var analyze_pc_btn = $VBoxContainer/Button

func _ready() -> void:
	if scanner_btn:
		scanner_btn.pressed.connect(_on_scanner_toggled)
	if clean_malware_btn:
		clean_malware_btn.pressed.connect(_on_clean_malware_pressed)
	if anti_ransomware_btn:
		anti_ransomware_btn.pressed.connect(_on_anti_ransomware_pressed)
	if analyze_file_btn:
		analyze_file_btn.pressed.connect(_on_analyze_file_pressed)
	if analyze_pc_btn:
		analyze_pc_btn.pressed.connect(func():
			var temp_screen = get_tree().root.get_node_or_null("Desktop")
			if temp_screen: temp_screen.show_toast("Computer Analysis completed. Everything in order.")
		)
		


func _process(_delta: float) -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		if screen_node.is_scanner_active:
			scanner_btn.text = "Active (Click to Deactivate)"
		else:
			scanner_btn.text = "Activate Scanner"
			
		if screen_node.is_anti_ransomware_active:
			anti_ransomware_btn.text = "Active (Click to Deactivate)"
		else:
			anti_ransomware_btn.text = "Activate Anti-Ransomware"

func _on_scanner_toggled() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		if screen_node.is_anti_ransomware_active:
			screen_node.show_toast("You cannot have the Scanner and Anti-Ransomware active at the same time.")
			return
		
		screen_node.is_scanner_active = !screen_node.is_scanner_active
		if screen_node.is_scanner_active:
			screen_node.show_toast("System scanner activated. CPU/RAM load at maximum.")
		else:
			screen_node.show_toast("System scanner deactivated.")

func _on_clean_malware_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		if not screen_node.system_permissions_revoked:
			screen_node.show_toast("Error: You must limit system permissions in Settings to clean viruses.")
			screen_node.add_log("FAILURE: Cleaning blocked. System permissions too high.", true)
			return
			
		var cleaned_something = false
		if screen_node.active_malware > 0:
			screen_node.active_malware = 0
			screen_node.show_toast("Malware units cleaned from the system.")
			screen_node.add_log("THREAT NEUTRALIZED: Malware deleted by the Antivirus.", false)
			cleaned_something = true
			
		if "has_active_trojan" in screen_node and screen_node.has_active_trojan:
			screen_node.has_active_trojan = false
			if not screen_node.has_active_ransomware:
				screen_node.game_over_timer = 0.0
			screen_node.show_toast("Trojan successfully removed from the system!")
			screen_node.add_log("THREAT NEUTRALIZED: Trojan deleted or blocked.", false)
			cleaned_something = true
			
		if not cleaned_something:
			screen_node.show_toast("The system is already clean of Malware and Trojans.")

func _on_anti_ransomware_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		# Purpose 1: Remove Ransomware if already infected
		if screen_node.has_active_ransomware:
			if screen_node.system_permissions_revoked:
				screen_node.has_active_ransomware = false
				screen_node.system_permissions_revoked = false
				if screen_node.game_over_timer > 0.0:
					screen_node.game_over_timer = 0.0
				screen_node.show_toast("Ransomware successfully removed from the system!")
				screen_node.add_log("THREAT NEUTRALIZED: Ransomware deleted. Permissions restored.", false)
			else:
				screen_node.show_toast("Error: Ransomware blocks access. Revoke advanced permissions in Options first.")
				screen_node.add_log("FAILURE: Ransomware blocks disinfection. Missing permissions.", true)
			return

		# Purpose 2: Activate/Deactivate preventive protection
		if screen_node.is_scanner_active:
			screen_node.show_toast("You cannot have Anti-Ransomware and Scanner active at the same time.")
			return
			
		screen_node.is_anti_ransomware_active = !screen_node.is_anti_ransomware_active
		if screen_node.is_anti_ransomware_active:
			screen_node.show_toast("Anti-Ransomware protection activated. CPU/RAM load at maximum.")
		else:
			screen_node.show_toast("Anti-Ransomware protection deactivated.")

func _on_analyze_file_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if not screen_node: return
	
	if not screen_node.is_scanner_active:
		screen_node.show_toast("Error: Scanner must be active to analyze and delete files.")
		return
		
	var file_manager = screen_node.get_node_or_null("CanvasLayer/FileManager")
	if file_manager:
		screen_node.can_delete_files = true
		file_manager.show()
		screen_node.show_toast("Active Analysis Mode: You can now manually delete files from the Manager.")
		screen_node.add_log("SCANNER: Analysis Mode temporarily enabled.", false)
