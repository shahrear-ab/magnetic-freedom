extends Control


# ==================================================
# BUTTON REFERENCES
# ==================================================

@onready var pause_title = $PausePanel/VBoxContainer/PauseTitle

@onready var start_button = $PausePanel/VBoxContainer/StartButton
@onready var resume_button = $PausePanel/VBoxContainer/ResumeButton
@onready var restart_button = $PausePanel/VBoxContainer/RestartButton
@onready var start_from_level_one_button = $PausePanel/VBoxContainer/StartFromLevel1Button
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
	# TITLE FONT SIZE
	# ==================================================

	pause_title.add_theme_font_size_override(
		"font_size",
		32
	)


	# ==================================================
	# CONNECT BUTTONS
	# ==================================================

	if not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)

	if not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)

	if not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)

	if not start_from_level_one_button.pressed.is_connected(_on_start_from_level_one_pressed):
		start_from_level_one_button.pressed.connect(_on_start_from_level_one_pressed)

	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)


	# ==================================================
	# CHECK IF GAME IS RESTARTING
	# ==================================================

	if get_tree().has_meta("restarting_game"):

		get_tree().remove_meta("restarting_game")

		# Hide pause menu after restart
		hide()

		# Start the newly loaded level
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


	# ==================================================
	# INITIAL TITLE
	# ==================================================

	pause_title.text = "MAGNETIC FREEDOM"
	pause_title.show()


	# ==================================================
	# SHOW
	# ==================================================

	start_button.show()
	quit_button.show()


	# ==================================================
	# HIDE
	# ==================================================

	resume_button.hide()
	restart_button.hide()
	start_from_level_one_button.hide()


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


	# ==================================================
	# START LEVEL AGAIN
	# ==================================================

	level_manager.start_level()
	get_tree().paused = false


	print("LEVEL TIMER RESET TO: ", level_manager.time_left)
	print("LEVEL ACTIVE: ", level_manager.level_active)

	print("================================")


# ==================================================
# START BUTTON
# ==================================================

func _on_start_pressed():

	# Button sound
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

		# Story must work while paused
		story_screen.process_mode = Node.PROCESS_MODE_ALWAYS

		story_screen.show_story()


	else:

		print("WARNING: StoryScreen not found!")
		print("Starting game without story.")


		# ==================================================
		# START LEVEL DIRECTLY
		# ==================================================

		var level_manager = get_tree().get_first_node_in_group(
			"level_manager"
		)


		if level_manager != null:

			level_manager.start_level()


		# Unpause game
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
				#
				# - Initial START screen
				# - Mission Failed
				# - All Missions Completed
				# - Story Screen
				#
				# These screens don't have Resume visible.

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
	AudioManager.stop_engine()
	AudioManager.stop_security_detect()


	# Button / pause sound
	AudioManager.play_pause()


	# ==================================================
	# TITLE
	# ==================================================

	pause_title.text = "PAUSED"
	pause_title.show()


	# ==================================================
	# RESET RESTART BUTTON TEXT
	# ==================================================

	restart_button.text = "RESTART CURRENT MISSION"


	# ==================================================
	# SHOW MENU
	# ==================================================

	show()


	# ==================================================
	# SHOW
	# ==================================================

	resume_button.show()
	restart_button.show()
	quit_button.show()


	# ==================================================
	# UPDATE START FROM LEVEL 1 VISIBILITY
	# ==================================================

	_update_start_from_level_one_visibility()


	# ==================================================
	# HIDE
	# ==================================================

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


	# Pause / resume sound
	AudioManager.play_pause()


	# Resume game
	get_tree().paused = false


	# Hide pause menu
	hide()


	print("GAME RESUMED")


# ==================================================
# RESUME BUTTON
# ==================================================

func _on_resume_pressed():

	# Button sound
	AudioManager.play_click()

	resume_game()


# ==================================================
# RESTART BUTTON
# ==================================================

func _on_restart_pressed():

	# Button sound
	AudioManager.play_click()
	AudioManager.stop_engine()
	AudioManager.stop_security_detect()


	print("================================")
	print("RESTART BUTTON PRESSED")
	print("================================")


	# ==================================================
	# TELL THE NEW SCENE THIS IS A RESTART
	# ==================================================

	var level_manager = get_tree().get_first_node_in_group(
		"level_manager"
	)

	if level_manager != null:

		get_tree().set_meta(
			"restarting_level_number",
			level_manager.level_number
		)

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

	# Button sound
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


	# ==================================================
	# TITLE
	# ==================================================

	pause_title.text = "MISSION FAILED"


	# ==================================================
	# UPDATE RESTART BUTTON TEXT
	# ==================================================

	restart_button.text = "RESTART CURRENT MISSION"


	# ==================================================
	# SHOW MENU
	# ==================================================

	show()


	# ==================================================
	# SHOW
	# ==================================================

	pause_title.show()
	restart_button.show()
	quit_button.show()


	# ==================================================
	# UPDATE START FROM LEVEL 1 VISIBILITY
	# ==================================================

	_update_start_from_level_one_visibility()


	# ==================================================
	# HIDE
	# ==================================================

	start_button.hide()
	resume_button.hide()


	# ==================================================
	# PAUSE EVERYTHING
	# ==================================================

	get_tree().paused = true


# ==================================================
# UPDATE START FROM LEVEL 1 VISIBILITY
# ==================================================

func _update_start_from_level_one_visibility():

	var level_manager = get_tree().get_first_node_in_group(
		"level_manager"
	)


	if level_manager == null:

		print("WARNING: LevelManager not found!")
		start_from_level_one_button.hide()

		return


	# ==================================================
	# SHOW IF LEVEL > 1, HIDE IF LEVEL == 1
	# ==================================================

	if level_manager.level_number > 1:

		start_from_level_one_button.show()

	else:

		start_from_level_one_button.hide()


# ==================================================
# ALL MISSIONS COMPLETE SCREEN
# ==================================================

func show_all_missions_complete():

	print("SHOWING ALL MISSIONS COMPLETE SCREEN")


	# ==================================================
	# TITLE
	# ==================================================

	pause_title.text = "ALL MISSIONS COMPLETED!"


	# ==================================================
	# SHOW MENU
	# ==================================================

	show()


	# ==================================================
	# SHOW
	# ==================================================

	pause_title.show()
	start_from_level_one_button.show()
	quit_button.show()


	# ==================================================
	# HIDE
	# ==================================================

	start_button.hide()
	resume_button.hide()
	restart_button.hide()


	# ==================================================
	# PAUSE EVERYTHING
	# ==================================================

	get_tree().paused = true


# ==================================================
# START FROM LEVEL 1 BUTTON
# ==================================================

func _on_start_from_level_one_pressed():

	# Button sound
	AudioManager.play_click()
	AudioManager.stop_engine()
	AudioManager.stop_security_detect()


	print("================================")
	print("START FROM LEVEL 1 BUTTON PRESSED")
	print("================================")


	# ==================================================
	# FIND LEVEL MANAGER
	# ==================================================

	var level_manager = get_tree().get_first_node_in_group(
		"level_manager"
	)


	if level_manager == null:

		print("WARNING: LevelManager not found!")

		return


	# ==================================================
	# RESET TO LEVEL 1
	# ==================================================

	level_manager.reset_to_level_one()


	# ==================================================
	# HIDE MENU
	# ==================================================

	hide()


	# ==================================================
	# UNPAUSE GAME
	# ==================================================

	get_tree().paused = false


	print("================================")
	print("GAME RESET TO LEVEL 1")
	print("================================")
