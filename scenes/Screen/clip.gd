extends Control

signal dialogue_started
signal dialogue_ended

var message_queue: Array[String] = []
var is_talking: bool = false

@onready var label: Label = $TextureRect/Label
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	label.text = ""
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if sprite.animation == "talking":
		sprite.play("idle")

func _input(event: InputEvent) -> void:
	
	if is_talking and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		if has_node("Clippy"):
			$Clippy.play()
	
		dismiss()

func start_intro() -> void:
	queue_message("Hi! I'm Clip, your digital assistant.")
	queue_message("You are currently at your computer, but something strange is happening...")
	queue_message("Viruses and fraudulent emails will constantly attack your computer.")
	queue_message("Your only option is to defend yourself by using antivirus software and avoiding online scams.")
	queue_message("The antivirus is located in the top section; use it to remove malware and detect threats.")
	queue_message("Your email address is also located at the top of the screen; you will need to use it to prevent online fraud.")
	queue_message("At the bottom you can view the system logs by pressing the red button.")
	queue_message("If you feel lost, there's a blue button which will show you a simple guide you'll need to complete the game.")
	queue_message("That's all you need to know; now it's your turn to be the protector of this computer.")
	queue_message("Remember, you have 10 minutes. Good luck!")

func queue_message(text: String) -> void:
	message_queue.append(text)
	if not is_talking:
		_show_next_message()

func _show_next_message() -> void:
	if message_queue.is_empty():
		_end_dialogue()
		return
	
	
	if not is_talking:
		is_talking = true
		emit_signal("dialogue_started")
		if has_node("Clippy"):
			$Clippy.play()
			
	label.text = message_queue.pop_front()
	sprite.play("talking")

func dismiss() -> void:
	if message_queue.is_empty():
		_end_dialogue()
	else:
		_show_next_message()

func _end_dialogue() -> void:
	is_talking = false
	label.text = ""
	sprite.play("idle")
	emit_signal("dialogue_ended")
