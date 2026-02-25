extends CanvasLayer

signal power_on_completed

@onready var animation_player = $AnimationPlayer
@onready var crt_rect = $CRTEffect

func _ready() -> void:
	crt_rect.modulate = Color(0,0,0,1)
	
	if animation_player.has_animation("power_on"):
		animation_player.play("power_on")
	else:
		_on_animation_finished("power_on")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "power_on":
		power_on_completed.emit()
		queue_free()
