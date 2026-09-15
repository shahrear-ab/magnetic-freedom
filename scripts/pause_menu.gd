extends Control


# ==================================================
# BUTTON REFERENCES
# ==================================================

@onready var pause_title = $PausePanel/VBoxContainer/PauseTitle

@onready var start_button = $PausePanel/VBoxContainer/StartButton
@onready var resume_button = $PausePanel/VBoxContainer/ResumeButton
@onready var restart_button = $PausePanel/VBoxContainer/RestartButton
@onready var keyboard_button = $PausePanel/VBoxContainer/KeyboardButton
@onready var quit_button = $PausePanel/VBoxContainer/QuitButton


# ==================================================
# READY
# ==================================================

func _ready():

	# Menu must work while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


	# ==================================================
	# CONNECT BUTTONS
	# ==================================================

	start_button.pressed.connect(_on_start_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	keyboard_button.pressed.connect(_on_keyboard_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


	# ==================================================
	# INITIAL START SCREEN
	# ==================================================

	# Pause the game immediately
	get_tree().paused = true

	# Show the menu
	show()


	# ==================================================
	# INITIAL SCREEN
	# ==================================================

	# SHOW
	start_button.show()
	keyboard_button.show()
	quit_button.show()


	# HIDE
	pause_title.hide()
	resume_button.hide()
	restart_button.hide()


	print("================================")
	print("GAME WAITING FOR START")
	print("================================")


# ==================================================
# START BUTTON
# ==================================================

func _on_start_pressed():

	print("================================")
	print("GAME STARTED")
	print("================================")

	# Hide the start menu
	hide()

	# Start the game
	get_tree().paused = false


# ==================================================
# ESC KEY
# ==================================================

func _input(event):

	if event is InputEventKey:

		if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:

			print("ESC PRESSED")

			if get_tree().paused:

				# Don't close the initial START screen
				if start_button.visible:
					return

				resume_game()

			else:

				pause_game()


# ==================================================
# PAUSE GAME
# ==================================================

func pause_game():

	print("PAUSING GAME")

	# Show pause menu
	show()


	# ==================================================
	# NORMAL PAUSE MENU
	# ==================================================

	# SHOW
	pause_title.show()
	resume_button.show()
	restart_button.show()
	keyboard_button.show()
	quit_button.show()


	# HIDE
	start_button.hide()


	# Pause game
	get_tree().paused = true

	print("GAME PAUSED")


# ==================================================
# RESUME GAME
# ==================================================

func resume_game():

	print("RESUMING GAME")

	# Unpause
	get_tree().paused = false

	# Hide menu
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

	# Unpause before restarting
	get_tree().paused = false

	# Reload current scene
	get_tree().reload_current_scene()


# ==================================================
# KEYBOARD BUTTON
# ==================================================

func _on_keyboard_pressed():

	print("KEYBOARD LAYOUT PRESSED")


# ==================================================
# QUIT BUTTON
# ==================================================

func _on_quit_pressed():

	print("QUITTING GAME")

	# Make sure game isn't paused
	get_tree().paused = false

	# Quit
	get_tree().quit()
