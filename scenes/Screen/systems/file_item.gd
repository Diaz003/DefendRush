extends HBoxContainer

signal file_executed(consequence_type)
signal file_deleted

var is_exe: bool = false
var exe_timer: float = 30.0
var consequence_type: int = 0
var base_name: String = ""

func _ready() -> void:
	if has_node("MarginContainer3/DeleteButton"):
		$MarginContainer3/DeleteButton.pressed.connect(_on_delete_pressed)

func setup(file_name: String, exe: bool) -> void:
	base_name = file_name
	$MarginContainer2/Label.text = file_name
	is_exe = exe
	if is_exe:
		consequence_type = randi() % 3 + 1
		exe_timer = randf_range(20.0, 45.0)
		set_process(true)
	else:
		set_process(false)

func _process(delta: float) -> void:
	if is_exe and exe_timer > 0.0:
		exe_timer -= delta
		if exe_timer <= 0.0:
			exe_timer = 0.0
			_execute_payload()
		else:
			# Update label with countdown
			$MarginContainer2/Label.text = base_name + "  [" + str(int(exe_timer)) + "s]"
			# Progressive colour: white -> yellow -> orange -> red
			if exe_timer > 20.0:
				modulate = Color(1, 1, 1)          # white – safe window
			elif exe_timer > 10.0:
				modulate = Color(1, 1, 0)           # yellow – caution
			elif exe_timer > 5.0:
				modulate = Color(1, 0.5, 0)         # orange – urgent
			else:
				modulate = Color(1, 0, 0)           # red – critical

func _execute_payload() -> void:
	file_executed.emit(consequence_type)
	$MarginContainer2/Label.text = base_name + "  [EXECUTED]"
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
		
		# Bonus for deleting threats before they execute
		if is_exe and exe_timer > 0.0:
			var bonus = 200
			if exe_timer > 20.0:
				bonus = 400  # Extra reward for catching early
			screen_node.score += bonus
			screen_node.show_toast("Threat neutralized! +" + str(bonus) + " pts!")
			screen_node.add_log("SECURITY: Deleted threat '" + base_name + "' before execution. +" + str(bonus) + " pts.", false)
		elif is_exe:
			# Already executed, still let them delete but smaller bonus
			screen_node.score += 50
			screen_node.show_toast("Cleaned executed malware. +50 pts")
			screen_node.add_log("CLEANUP: Removed executed malware '" + base_name + "'. +50 pts.", false)
			if screen_node.active_malware > 0:
				screen_node.active_malware -= 1
	
	file_deleted.emit()
	queue_free()
