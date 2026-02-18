extends Control

@onready var cam: Camera2D = $Camera2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var title = $Title
@onready var buttons = $Buttons
@onready var desktop: Control = $Desktop

func _ready():
	cam.make_current()
	desktop.visible = false

func _on_play_button_pressed() -> void:
	$Buttons/PlayButton.disabled = true
	anim.play("fade_out_ui") 

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func start_zoom() -> void:
	title.visible = false
	buttons.visible = false
	anim.play("start_sequence") 

func start_game() -> void:
	desktop.visible = true
