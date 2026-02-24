extends Panel

@onready var cpu_bar = $VBoxContainer/CPUContainer/CPUBar
@onready var ram_bar = $VBoxContainer/RAMContainer/RAMBar
@onready var vbox = $VBoxContainer
@onready var permissions_container = $PermissionsContainer
@onready var permissions_btn = $VBoxContainer/PermissionsButton
@onready var back_btn = $PermissionsContainer/TitleBox/BackButton
@onready var password_add = $PasswordAdd

const BASE_CPU = 25.0
const BASE_RAM = 40.0
const SCANNER_CPU_COST    = 50.0
const SCANNER_RAM_COST    = 35.0
const RANSOMWARE_CPU_COST = 45.0
const RANSOMWARE_RAM_COST = 30.0

func _ready() -> void:
	password_add.hide()
	permissions_container.hide()
	permissions_btn.pressed.connect(_on_permissions_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	
	if has_node("PasswordAdd/Panel/LineEdit"):
		$PasswordAdd/Panel/LineEdit.text_submitted.connect(_on_password_submitted)

# Paso 1 → Paso 2: muestra la pantalla de contraseña
func _on_permissions_pressed() -> void:
	vbox.hide()
	password_add.show()

# Paso 2 → Paso 3: contraseña correcta, muestra permisos
func _on_password_submitted(new_text: String) -> void:
	if new_text.strip_edges() == "ThisIsMyPassword":
		$PasswordAdd/Panel/LineEdit.text = ""
		password_add.hide()
		permissions_container.show()
	else:
		$PasswordAdd/Panel/LineEdit.text = ""

# Paso 3 → Paso 1: vuelve a la pantalla principal
func _on_back_pressed() -> void:
	permissions_container.hide()
	vbox.show()

func _process(_delta: float) -> void:
	var desktop = get_tree().root.get_node_or_null("Desktop")
	if not desktop:
		return
	if desktop.is_scanner_active:
		cpu_bar.value = BASE_CPU + SCANNER_CPU_COST
		ram_bar.value = BASE_RAM + SCANNER_RAM_COST
	elif desktop.is_anti_ransomware_active:
		cpu_bar.value = BASE_CPU + RANSOMWARE_CPU_COST
		ram_bar.value = BASE_RAM + RANSOMWARE_RAM_COST
	else:
		cpu_bar.value = BASE_CPU
		ram_bar.value = BASE_RAM
