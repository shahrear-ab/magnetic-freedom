extends Control


# ==================================================
# BUTTON REFERENCES
# ==================================================

@onready var resume_button = $PausePanel/VBoxContainer/ResumeButton
@onready var restart_button = $PausePanel/VBoxContainer/RestartButton
@onready var keyboard_button = $PausePanel/VBoxContainer/KeyboardButton
@onready var quit_button = $PausePanel/VBoxContainer/QuitButton


# ==================================================
# READY
# ==================================================

func _ready():

	# Hide pause menu at the beginning
	hide()

	# Connect buttons
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	keyboard_button.pressed.connect(_on_keyboard_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	print("================================")
	print("PAUSE MENU READY")
	print("================================")


# ==================================================
# ESC KEY
# ==================================================

func _input(event):

	if event is InputEventKey:

		if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:

			print("ESC PRESSED")

			if get_tree().paused:

				resume_game()

			else:

				pause_game()


# ==================================================
# PAUSE GAME
# ==================================================

func pause_game():

	print("PAUSING GAME")

	show()

	get_tree().paused = true

	print("GAME PAUSED")


# ==================================================
# RESUME GAME
# ==================================================

func resume_game():

	print("RESUMING GAME")

	get_tree().paused = false

	hide()

	print("GAME RESUMED")


# ==================================================
# RESUME BUTTON
# ==================================================

func _on_resume_pressed():

	resume_game()


# ==================================================
# RESTART BUTTON
# ==================================================

func _on_restart_pressed():

	print("RESTARTING GAME")

	get_tree().paused = false

	get_tree().reload_current_scene()


# ==================================================
# KEYBOARD LAYOUT
# ==================================================

func _on_keyboard_pressed():

	print("KEYBOARD LAYOUT PRESSED")


# ==================================================
# QUIT GAME
# ==================================================

func _on_quit_pressed():

	print("QUITTING GAME")

	get_tree().paused = false

	get_tree().quit()
