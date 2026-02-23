extends Control

var time_left_seconds: float = 10 * 60.0  
var last_update_second: int = 0

@onready var time_label: Label = $Toolbar/utils/HourText/Text

func _ready() -> void:
	$CanvasLayer/Antivirus.hide()
	$CanvasLayer/BankWindow.hide()
	$CanvasLayer/BrowserWindows.hide()
	$CanvasLayer/FileManager.hide()
	$CanvasLayer/SteamWindow.hide()

	$ExplorerButton.pressed.connect(func(): $CanvasLayer/BrowserWindows.show())
	$PayPalButton.pressed.connect(func(): $CanvasLayer/BankWindow.show())
	$SteamButton.pressed.connect(func(): $CanvasLayer/SteamWindow.show())
	$FileButton.pressed.connect(func(): $CanvasLayer/FileManager.show())
	$SecureButton.pressed.connect(func(): $CanvasLayer/Antivirus.show())
	$Toolbar/utils/Guide.pressed.connect(func(): $CanvasLayer/Guide.show())

	_update_time_label()

func _process(delta: float) -> void:
	if time_left_seconds > 0.0:
		time_left_seconds -= delta

		var current_second: int = int(time_left_seconds)
		if current_second != last_update_second:
			last_update_second = current_second
			_update_time_label()

		if time_left_seconds <= 0.0:
			time_left_seconds = 0.0
			_update_time_label()
			_on_game_end()

func _update_time_label() -> void:
	var total: int = int(time_left_seconds)
	var minutes: int = int(total / 60.0)  
	var seconds: int = int(total % 60)
	time_label.text = "%02d:%02d" % [minutes, seconds]

func _on_game_end() -> void:
	set_process(false)
