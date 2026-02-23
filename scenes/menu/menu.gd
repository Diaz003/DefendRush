extends Control

@onready var cam: Camera2D = $Camera2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var title = $Title
@onready var buttons = $Buttons
@onready var xp_video: VideoStreamPlayer = $XPVideo

func _ready():
	cam.make_current()
	xp_video.visible = false

func _on_play_button_pressed() -> void:
	$Buttons/PlayButton.disabled = true
	anim.play("fade_out_ui")

func _on_fade_out_finished(anim_name: String) -> void:
	if anim_name == "fade_out_ui":
		anim.animation_finished.disconnect(_on_fade_out_finished)
		start_zoom() 

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func start_zoom() -> void:
	title.visible = false
	buttons.visible = false
	anim.play("start_sequence")
	
	anim.animation_finished.connect(_on_start_sequence_finished)

func _on_start_sequence_finished(anim_name: String) -> void:
	if anim_name == "start_sequence":
		anim.animation_finished.disconnect(_on_start_sequence_finished)
		xp_video.visible = true
		xp_video.play()


func _on_xp_video_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/Screen/Screen.tscn")
