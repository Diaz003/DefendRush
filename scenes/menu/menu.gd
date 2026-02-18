extends Control

@onready var cam: Camera2D = $Camera2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var title = $Title
@onready var buttons = $Buttons

func _ready():
	cam.make_current()

func _on_play_button_pressed() -> void:
	title.visible = false
	buttons.visible = false
	anim.play("start_sequence") 

func _on_exit_button_pressed() -> void:
	get_tree().quit()
