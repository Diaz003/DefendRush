extends CanvasLayer

@onready var label = $Panel/Label
@onready var anim = $AnimationPlayer

func _ready() -> void:
	# Hide initially, wait to be triggered by show_toast
	$Panel.modulate = Color(1,1,1,0)

func show_toast(message: String) -> void:
	label.text = message
	anim.stop()
	anim.play("show")
