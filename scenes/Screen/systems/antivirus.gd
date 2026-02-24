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
			if temp_screen: temp_screen.show_toast("Análisis de Computadora completado. Todo en orden.")
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
			screen_node.show_toast("No puedes tener el Escáner y el Anti-Ransomware activos al mismo tiempo.")
			return
		
		screen_node.is_scanner_active = !screen_node.is_scanner_active
		if screen_node.is_scanner_active:
			screen_node.show_toast("Escáner del sistema activado. Carga de CPU/RAM al máximo.")
		else:
			screen_node.show_toast("Escáner del sistema desactivado.")

func _on_clean_malware_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		if screen_node.active_malware > 0:
			screen_node.active_malware -= 1
			screen_node.show_toast("Unidades de Malware limpiadas del sistema.")
			screen_node.add_log("AMENAZA NEUTRALIZADA: Malware estándar eliminado por el Antivirus.", false)
		else:
			screen_node.show_toast("El sistema está limpio de Malware estándar.")

func _on_anti_ransomware_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		# Finalidad 1: Eliminar Ransomware si ya estamos infectados
		if screen_node.has_active_ransomware:
			if screen_node.system_permissions_revoked:
				screen_node.has_active_ransomware = false
				screen_node.system_permissions_revoked = false
				if screen_node.game_over_timer > 0.0:
					screen_node.game_over_timer = 0.0
				screen_node.show_toast("¡Ransomware eliminado con éxito del sistema!")
				screen_node.add_log("AMENAZA NEUTRALIZADA: Ransomware eliminado. Permisos restaurados.", false)
			else:
				screen_node.show_toast("Error: El Ransomware bloquea el acceso. Revoca primero los permisos avanzados en Opciones.")
				screen_node.add_log("FALLO: Ransomware bloquea la desinfección. Faltan permisos.", true)
			return

		# Finalidad 2: Activar/Desactivar protección preventiva
		if screen_node.is_scanner_active:
			screen_node.show_toast("No puedes tener el Anti-Ransomware y el Escáner activos al mismo tiempo.")
			return
			
		screen_node.is_anti_ransomware_active = !screen_node.is_anti_ransomware_active
		if screen_node.is_anti_ransomware_active:
			screen_node.show_toast("Protección Anti-Ransomware activada. Carga de CPU/RAM al máximo.")
		else:
			screen_node.show_toast("Protección Anti-Ransomware desactivada.")

func _on_analyze_file_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if not screen_node: return
	
	if not screen_node.is_scanner_active:
		screen_node.show_toast("Error: El Escáner debe estar activo para analizar y eliminar archivos.")
		return
		
	var file_manager = screen_node.get_node_or_null("CanvasLayer/FileManager")
	if file_manager:
		screen_node.can_delete_files = true
		file_manager.show()
		screen_node.show_toast("Modo Análisis Activo: Ahora puedes eliminar archivos manualmente desde el Gestor.")
		screen_node.add_log("ESCANER: Modo Análisis habilitado temporalmente.", false)
