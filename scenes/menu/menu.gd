extends Control

@onready var cam: Camera2D = $Camera2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var title = $Title
@onready var buttons = $Buttons
@onready var xp_video: VideoStreamPlayer = $XPVideo

@onready var settings_control = $SettingsControl
@onready var fullscreen_check = $SettingsControl/VBoxContainer/FullscreenCheck
@onready var volume_slider = $SettingsControl/VBoxContainer/VolumeSlider

func _ready():
	cam.make_current()
	xp_video.visible = false
	settings_control.visible = false
	
	fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	volume_slider.value = AudioServer.get_bus_volume_db(0)

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

func _on_settings_button_pressed() -> void:
	buttons.visible = false
	title.visible = false
	settings_control.visible = true

func _on_back_button_pressed() -> void:
	settings_control.visible = false
	buttons.visible = true
	title.visible = true

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	if value == volume_slider.min_value:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
