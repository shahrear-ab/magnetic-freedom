extends Control


# ==================================================
# REFERENCES
# ==================================================

@onready var story_text = $StoryContainer/StoryText
@onready var title = $StoryContainer/Title

@onready var image1 = $StoryContainer/ImageContainer/Image1
@onready var image2 = $StoryContainer/ImageContainer/Image2

@onready var next_button = $StoryContainer/NextButton


# ==================================================
# STORY PAGES
# ==================================================

var story_pages = [

	{
		"title": "OPERATION: MAGNETIC FREEDOM",

		"text":
		"\nSome valuable components have been stolen from BUET Robotics Society’s secret research project.\n\n" +
		"Deep inside a restricted industrial facility, those " +
		"valuable parts from the secret research project are being held by a " +
		"corporate group determined to stop the reasearch project from reaching the public.\n\n" +
		"The research was never meant for profit.\n" +
		"It was being developed intended to serve society.",

		"image1": preload("res://assets/story/page1_1.png"),
		"image2": preload("res://assets/story/page1_2.png")
	},


	{
		"title": "THE MISSION",

		"text":
		"\nBUET Robotics Society cannot risk sending people into the facility.\n\n" +
		"So a specialized machine has been deployed 'the MagneticFreedom Bot'.\n\n" +
		"Your mission is simple:\n\n" +
		"Recover the stolen research components and bring them safely back " +
		"to the designated delivery zone.",

		"image1": preload("res://assets/story/page2_1.png"),
		"image2": preload("res://assets/story/page2_2.png")
	},


	{
		"title": "STEALTH PROTOCOL",

		"text":
		"\nBut there is one problem.\n\n" +
		"The factory floor is being monitored by autonomous security bots.\n\n" +
		"If a security bot detects the MagneticFreedom Bot, you will have only " +
		"2 seconds to escape its detection zone.\n\n" +
		"Stay too long...\n\n" +
		"MISSION FAILED.",

		"image1": preload("res://assets/story/page3_1.png"),
		"image2": preload("res://assets/story/page3_2.png")
	},


	{
		"title": "RECOVERY PROTOCOL",

		"text":
		"\nUse the MagneticFreedom Bot's robotic arm and magnetic system to " +
		"retrieve the stolen components.\n\n" +
		"Transport every required box to the delivery zone.\n\n" +
		"Stay alert. Plan your route. Avoid detection.",

		"image1": preload("res://assets/story/page4_1.png"),
		"image2": preload("res://assets/story/page4_2.png")
	},


	{
		"title": "FIVE MISSIONS",

		"text":
		"\nThe operation consists of five increasingly difficult missions.\n\n" +
		"Each mission will require you to recover more components while " +
		"working against the clock and avoiding the security bots.\n\n" +
		"Complete all five missions.\n\n" +
		"Recover the research.\n\n" +
		"Bring Magnetic Freedom home.",

		"image1": preload("res://assets/story/page5_1.png"),
		"image2": preload("res://assets/story/page5_2.png")
	}

]


# ==================================================
# CURRENT PAGE
# ==================================================

var current_page: int = 0


# ==================================================
# READY
# ==================================================

func _ready():

	# ==================================================
	# STORY SCREEN MUST NOT APPEAR AUTOMATICALLY
	# ==================================================

	hide()


	# ==================================================
	# STORY MUST WORK WHILE GAME IS PAUSED
	# ==================================================

	process_mode = Node.PROCESS_MODE_ALWAYS


	# ==================================================
	# CONNECT BUTTON
	# ==================================================

	if not next_button.pressed.is_connected(_on_next_button_pressed):

		next_button.pressed.connect(
			_on_next_button_pressed
		)


	# ==================================================
	# PREPARE FIRST PAGE
	# ==================================================

	update_story()


# ==================================================
# SHOW STORY
# ==================================================

func show_story():

	print("==============================")
	print("SHOWING STORY")
	print("==============================")


	# Start from page 1

	current_page = 0


	# Keep game paused during story

	get_tree().paused = true


	# Hide normal HUD

	hide_game_hud()


	# Update page

	update_story()


	# Show story

	show()


# ==================================================
# HIDE GAME HUD DURING STORY
# ==================================================

func hide_game_hud():

	var hud = get_node_or_null("../HUD")

	if hud == null:

		print("WARNING: HUD NOT FOUND")

		return


	# ==================================================
	# LEVEL / BOXES / TIME
	# ==================================================

	var level_label = hud.get_node_or_null(
		"LevelLabel"
	)

	if level_label != null:

		level_label.hide()


	# ==================================================
	# MISSION MESSAGE
	# ==================================================

	var mission_message = hud.get_node_or_null(
		"MissionMessage"
	)

	if mission_message != null:

		mission_message.hide()


	# ==================================================
	# SECURITY WARNING
	# ==================================================

	var security_warning = hud.get_node_or_null(
		"SecurityWarning"
	)

	if security_warning != null:

		security_warning.hide()


	# ==================================================
	# CONTROLS PANEL
	# ==================================================

	var controls_panel = hud.get_node_or_null(
		"ControlsPanel"
	)

	if controls_panel != null:

		controls_panel.hide()


	# ==================================================
	# PAUSE MENU
	# ==================================================

	var pause_menu = hud.get_node_or_null(
		"PauseMenu"
	)

	if pause_menu != null:

		pause_menu.hide()


# ==================================================
# SHOW GAME HUD AFTER STORY
# ==================================================

func show_game_hud():

	var hud = get_node_or_null("../HUD")

	if hud == null:

		print("WARNING: HUD NOT FOUND")

		return


	# ==================================================
	# LEVEL / BOXES / TIME
	# ==================================================

	var level_label = hud.get_node_or_null(
		"LevelLabel"
	)

	if level_label != null:

		level_label.show()


	# ==================================================
	# CONTROLS
	# ==================================================

	var controls_panel = hud.get_node_or_null(
		"ControlsPanel"
	)

	if controls_panel != null:

		controls_panel.show()


# ==================================================
# UPDATE STORY
# ==================================================

func update_story():

	if current_page >= story_pages.size():

		return


	var page = story_pages[current_page]


	# ==================================================
	# UPDATE TITLE
	# ==================================================

	title.text = page["title"]


	# ==================================================
	# UPDATE STORY TEXT
	# ==================================================

	story_text.text = page["text"]


	# ==================================================
	# UPDATE IMAGE 1
	# ==================================================

	image1.texture = page["image1"]


	# ==================================================
	# UPDATE IMAGE 2
	# ==================================================

	image2.texture = page["image2"]


	# ==================================================
	# UPDATE BUTTON
	# ==================================================

	if current_page == story_pages.size() - 1:

		next_button.text = "START MISSION"

	else:

		next_button.text = "CONTINUE"


	print(
		"STORY PAGE: ",
		current_page + 1,
		" / ",
		story_pages.size()
	)


# ==================================================
# NEXT BUTTON
# ==================================================

func _on_next_button_pressed():

	# ==================================================
	# BUTTON SOUND
	# ==================================================

	AudioManager.play_click()


	# ==================================================
	# NEXT PAGE
	# ==================================================

	current_page += 1


	# ==================================================
	# STORY FINISHED
	# ==================================================

	if current_page >= story_pages.size():

		start_game()

		return


	# ==================================================
	# SHOW NEXT PAGE
	# ==================================================

	update_story()


# ==================================================
# START GAME
# ==================================================

func start_game():

	print("==============================")
	print("STORY COMPLETE")
	print("STARTING MISSION")
	print("==============================")


	# ==================================================
	# HIDE STORY
	# ==================================================

	hide()


	# ==================================================
	# FIND LEVEL MANAGER
	# ==================================================

	var level_manager = get_node_or_null(
		"../LevelManager"
	)


	if level_manager == null:

		print("==============================")
		print("ERROR: LEVEL MANAGER NOT FOUND!")
		print("==============================")

		return


	# ==================================================
	# START LEVEL
	# ==================================================
	#
	# This initializes:
	#
	# time_left = level_time
	# delivered_boxes = 0
	# level_active = true
	# mission_finished = false
	#
	# Therefore the timer starts correctly.
	# ==================================================

	level_manager.start_level()


	# ==================================================
	# SHOW GAME HUD
	# ==================================================

	show_game_hud()


	# ==================================================
	# UNPAUSE GAME
	# ==================================================

	get_tree().paused = false


	print("==============================")
	print(
		"LEVEL ",
		level_manager.level_number,
		" ACTIVE"
	)
	print(
		"TIMER STARTED: ",
		level_manager.time_left
	)
	print("==============================")
