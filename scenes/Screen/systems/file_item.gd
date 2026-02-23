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
	file_deleted.emit()
	queue_free()
