extends Control

@onready var container = $Panel/WindowContent/ScrollContainer/VBoxContainer
var max_logs: int = 10

func _ready() -> void:
	for child in container.get_children():
		child.queue_free()

func add_log(message: String, is_warning: bool = false) -> void:
	var label = Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var font = preload("res://assets/Letter/W95FA.otf")
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 20)
	
	if is_warning:
		label.add_theme_color_override("font_color", Color(1, 0, 0)) # Red
	else:
		label.add_theme_color_override("font_color", Color(0, 0, 0)) # Black
		
	container.add_child(label)
	
	var children = container.get_children()
	if children.size() > max_logs:
		children[0].queue_free()

func _on_close_button_pressed() -> void:
	hide()
