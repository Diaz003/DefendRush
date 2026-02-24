extends HBoxContainer

signal file_executed(consequence_type)
signal file_deleted

var is_exe: bool = false
var exe_timer: float = 3.0 * 60.0

func _ready() -> void:
	if has_node("MarginContainer3/DeleteButton"):
		$MarginContainer3/DeleteButton.pressed.connect(_on_delete_pressed)

func setup(file_name: String, exe: bool) -> void:
	$MarginContainer2/Label.text = file_name
	is_exe = exe
	if is_exe:
		set_process(true)
	else:
		set_process(false)

func _process(delta: float) -> void:
	if is_exe and exe_timer > 0.0:
		exe_timer -= delta
		if exe_timer <= 0.0:
			exe_timer = 0.0
			_execute_payload()

func _execute_payload() -> void:
	var consequence = randi() % 3 + 1
	file_executed.emit(consequence)
	modulate = Color(1, 0, 0)
	if has_node("MarginContainer3/DeleteButton"):
		$MarginContainer3/DeleteButton.hide()
	set_process(false)

func _on_delete_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		if screen_node.has("has_active_ransomware") and screen_node.has_active_ransomware:
			screen_node.show_toast("Permiso Denegado: Ransomware bloqueando acceso a archivos administrativos.")
			return
		if screen_node.has("can_delete_files") and not screen_node.can_delete_files:
			screen_node.show_toast("Permiso Denegado: Usa el Antivirus ('Analyze an file?') para habilitar el borrado manual.")
			return
			
	file_deleted.emit()
	queue_free()
