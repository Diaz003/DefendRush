extends HBoxContainer

signal mail_handled(is_malicious: bool, accept: bool)

var is_malicious: bool = false
var malicious_type: int = 0

func _ready() -> void:
	if has_node("Button"):
		$Button.pressed.connect(_on_accept)
	if has_node("Button2"):
		$Button2.pressed.connect(_on_delete)

func setup(subject: String, body: String, malicious: bool, type: int) -> void:
	is_malicious = malicious
	malicious_type = type

	var display_subject = subject
	if is_malicious:
		display_subject = "[!] " + subject
		modulate = Color(1.0, 0.55, 0.55)  # red tint for phishing

	if has_node("MarginContainer/Label"):
		$MarginContainer/Label.text = display_subject
	if has_node("MarginContainer2/Label2"):
		$MarginContainer2/Label2.text = body

func _on_accept() -> void:
	mail_handled.emit(is_malicious, true)
	queue_free()

func _on_delete() -> void:
	mail_handled.emit(is_malicious, false)
	queue_free()
