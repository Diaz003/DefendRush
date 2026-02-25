extends CanvasLayer

@onready var label = $Panel/Label
@onready var anim = $AnimationPlayer

func _ready() -> void:
	$Panel.modulate = Color(1,1,1,0)

func show_toast(message: String) -> void:
	label.text = message
	anim.stop()
	anim.play("show")
