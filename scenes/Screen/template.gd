extends Control

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

const EDGE_MARGIN: float = 40.0 # píxeles que siempre quedan dentro

func _ready() -> void:
	var title_bar: Control = $Panel/TitleBar
	var panel_litt: Control = $Panel
	var close_btn: BaseButton = $Panel/TitleBar/CloseButton

	title_bar.gui_input.connect(_on_drag_area_gui_input)
	panel_litt.gui_input.connect(_on_drag_area_gui_input)


func _on_drag_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
		_clamp_to_screen()


func _on_close_button_pressed() -> void:
	queue_free()


func _clamp_to_screen() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var margin: float = 40.0

	var min_x: float = -size.x + margin
	var max_x: float = viewport_size.x - margin
	var min_y: float = -size.y + margin
	var max_y: float = viewport_size.y - margin

	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)
