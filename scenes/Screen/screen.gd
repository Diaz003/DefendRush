extends Control

func _ready() -> void:
	$Antivirus.hide()
	$BankWindow.hide()
	$BrowserWindows.hide()
	$FileManager.hide()
	$Guide.hide()
	$SteamWindow.hide()

	$ExplorerButton.pressed.connect(func(): $BrowserWindows.show())
	$PayPalButton.pressed.connect(func(): $BankWindow.show())
	$SteamButton.pressed.connect(func(): $SteamWindow.show())
	$FileButton.pressed.connect(func(): $FileManager.show())
	$SecureButton.pressed.connect(func(): $Antivirus.show())
	$Toolbar/utils/Guide.pressed.connect(func(): $Guide.show())
 
