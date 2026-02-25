extends HBoxContainer

signal file_executed(consequence_type)
signal file_deleted

var is_exe: bool = false
var exe_timer: float = 30.0
var consequence_type: int = 0

func _ready() -> void:
	if has_node("MarginContainer3/DeleteButton"):
		$MarginContainer3/DeleteButton.pressed.connect(_on_delete_pressed)

func setup(file_name: String, exe: bool) -> void:
	$MarginContainer2/Label.text = file_name
	is_exe = exe
	if is_exe:
		consequence_type = randi() % 3 + 1
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
	file_executed.emit(consequence_type)
	modulate = Color(1, 0, 0)
	if has_node("MarginContainer3/DeleteButton"):
		$MarginContainer3/DeleteButton.hide()
	set_process(false)

func _on_delete_pressed() -> void:
	var screen_node = get_tree().root.get_node_or_null("Desktop")
	if screen_node:
		if "has_active_ransomware" in screen_node and screen_node.has_active_ransomware:
			screen_node.show_toast("Permission Denied: Ransomware blocking access to administrative files.")
			return
		if "can_delete_files" in screen_node and not screen_node.can_delete_files:
			screen_node.show_toast("Permission Denied: Use the Antivirus ('Analyze an file?') to enable manual deletion.")
			return
			
	file_deleted.emit()
	queue_free()
