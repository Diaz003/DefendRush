extends Panel

@onready var anti_ransomware_btn = $VBoxContainer/Button4

func _ready() -> void:
	if anti_ransomware_btn:
		anti_ransomware_btn.pressed.connect(_on_anti_ransomware_pressed)

func _on_anti_ransomware_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		if screen_node.antivirus_permissions_granted:
			if screen_node.game_over_timer > 0.0:
				screen_node.game_over_timer = 0.0
				screen_node.show_toast("Ransomware eliminado con éxito del sistema.")
				screen_node.add_log("AMENAZA NEUTRALIZADA: Ransomware eliminado por el Antivirus (Permisos de Admin).", false)
			else:
				screen_node.show_toast("No hay ransomware activo en el sistema.")
		else:
			screen_node.show_toast("Error: El Antivirus necesita permisos de Administrador para esta acción.")
			screen_node.add_log("FALLO DE ANTIVIRUS: Faltan permisos de Administrador para eliminar Ransomware.", true)
