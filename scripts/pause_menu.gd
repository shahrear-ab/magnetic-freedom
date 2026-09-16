extends Control


# ==================================================
# BUTTON REFERENCES
# ==================================================

@onready var pause_title = $PausePanel/VBoxContainer/PauseTitle

@onready var start_button = $PausePanel/VBoxContainer/StartButton
@onready var resume_button = $PausePanel/VBoxContainer/ResumeButton
@onready var restart_button = $PausePanel/VBoxContainer/RestartButton
@onready var quit_button = $PausePanel/VBoxContainer/QuitButton


# ==================================================
# READY
# ==================================================

func _ready():

	# ==================================================
	# MENU MUST WORK WHILE GAME IS PAUSED
	# ==================================================

	process_mode = Node.PROCESS_MODE_ALWAYS


	# ==================================================
	# CONNECT BUTTONS
	# ==================================================

	if not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)

	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)

	if not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)

	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)


	# ==================================================
	# CHECK IF GAME IS RESTARTING
	# ==================================================

	if get_tree().has_meta("restarting_game"):

		get_tree().remove_meta("restarting_game")

		# Hide pause menu after restart
		hide()

		# Make sure game is running
		get_tree().paused = false


		# ==================================================
		# START THE NEW LEVEL
		# ==================================================
		#
		# The new LevelManager starts with:
		#
		# time_left = 0
		# level_active = false
		#
		# So we explicitly call start_level().
		#
		# call_deferred() is important because we want
		# to wait until the newly reloaded scene has
		# completely initialized.
		# ==================================================

		call_deferred("_start_restarted_level")


		print("================================")
		print("GAME RESTARTED")
		print("================================")

		return


	# ==================================================
	# INITIAL START SCREEN
	# ==================================================

	get_tree().paused = true

	show()


	# SHOW
	start_button.show()
	quit_button.show()


	# HIDE
	pause_title.hide()
	resume_button.hide()
	restart_button.hide()


	print("================================")
	print("GAME WAITING FOR START")
	print("================================")


# ==================================================
# START RESTARTED LEVEL
# ==================================================

func _start_restarted_level():

	var level_manager = get_tree().get_first_node_in_group(
		"level_manager"
	)


	if level_manager == null:

		print("WARNING: LevelManager not found after restart!")

		return


	print("================================")
	print("RESTARTING CURRENT LEVEL")
	print("STARTING LEVEL TIMER")
	print("================================")


	# Start the level properly
	level_manager.start_level()


	print("LEVEL TIMER RESET TO: ", level_manager.time_left)
	print("LEVEL ACTIVE: ", level_manager.level_active)

	print("================================")


# ==================================================
# START BUTTON
# ==================================================

func _on_start_pressed():

	# 🔊 BUTTON CLICK
	AudioManager.play_click()


	print("================================")
	print("START BUTTON PRESSED")
	print("OPENING STORY")
	print("================================")


	# ==================================================
	# HIDE START MENU
	# ==================================================

	hide()


	# ==================================================
	# FIND STORY SCREEN
	# ==================================================

	var story_screen = get_node_or_null("../../StoryScreen")


	if story_screen != null:

		print("STORY SCREEN FOUND")


		# Story must be able to work while paused
		story_screen.process_mode = Node.PROCESS_MODE_ALWAYS


		story_screen.show_story()


	else:

		print("WARNING: StoryScreen not found!")
		print("Starting game without story.")


		# Start the level even if story is missing
		var level_manager = get_tree().get_first_node_in_group(
			"level_manager"
		)


		if level_manager != null:

			level_manager.start_level()


		get_tree().paused = false


# ==================================================
# ESC KEY
# ==================================================

func _input(event):

	if event is InputEventKey:

		if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:

			print("ESC PRESSED")


			# ==================================================
			# GAME IS PAUSED
			# ==================================================

			if get_tree().paused:

				# Don't resume after:
				# - Initial START screen
				# - Mission Failed
				# - All Missions Completed
				# - Story Screen

				if not resume_button.visible:

					return


				resume_game()


			# ==================================================
			# GAME IS RUNNING
			# ==================================================

			else:

				pause_game()


# ==================================================
# PAUSE GAME
# ==================================================

func pause_game():

	print("PAUSING GAME")


	# 🔊 PAUSE SOUND
	AudioManager.play_pause()


	show()


	# SHOW
	pause_title.show()
	resume_button.show()
	restart_button.show()
	quit_button.show()


	# HIDE
	start_button.hide()


	# ==================================================
	# PAUSE EVERYTHING
	# ==================================================

	get_tree().paused = true


	print("GAME PAUSED")


# ==================================================
# RESUME GAME
# ==================================================

func resume_game():

	print("RESUMING GAME")


	# 🔊 PAUSE / RESUME SOUND
	AudioManager.play_pause()


	get_tree().paused = false

	hide()


	print("GAME RESUMED")


# ==================================================
# RESUME BUTTON
# ==================================================

func _on_resume_pressed():

	# 🔊 BUTTON CLICK
	AudioManager.play_click()

	resume_game()


# ==================================================
# RESTART BUTTON
# ==================================================

func _on_restart_pressed():

	# 🔊 BUTTON CLICK
	AudioManager.play_click()


	print("================================")
	print("RESTART BUTTON PRESSED")
	print("================================")


	# ==================================================
	# TELL THE NEW SCENE THAT THIS IS A RESTART
	# ==================================================

	get_tree().set_meta(
		"restarting_game",
		true
	)


	# ==================================================
	# UNPAUSE BEFORE RELOADING
	# ==================================================

	get_tree().paused = false


	# ==================================================
	# RELOAD CURRENT SCENE
	# ==================================================

	get_tree().reload_current_scene()


# ==================================================
# QUIT BUTTON
# ==================================================

func _on_quit_pressed():

	# 🔊 BUTTON CLICK
	AudioManager.play_click()

	print("QUITTING GAME")


	# Make sure game isn't paused
	get_tree().paused = false


	# Quit game
	get_tree().quit()


# ==================================================
# MISSION FAILED SCREEN
# ==================================================

func show_mission_failed():

	print("SHOWING MISSION FAILED SCREEN")


	show()


	pause_title.text = "MISSION FAILED"


	# SHOW
	pause_title.show()
	restart_button.show()
	quit_button.show()


	# HIDE
	start_button.hide()
	resume_button.hide()


	# ==================================================
	# PAUSE EVERYTHING
	# ==================================================

	get_tree().paused = true


# ==================================================
# ALL MISSIONS COMPLETE SCREEN
# ==================================================

func show_all_missions_complete():

	print("SHOWING ALL MISSIONS COMPLETE SCREEN")


	show()


	pause_title.text = "ALL MISSIONS COMPLETED!"


	# SHOW
	pause_title.show()
	restart_button.show()
	quit_button.show()


	# HIDE
	start_button.hide()
	resume_button.hide()


	# ==================================================
	# PAUSE EVERYTHING
	# ==================================================

	get_tree().paused = true
