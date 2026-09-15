extends CanvasLayer


# ==================================================
# HUD REFERENCES
# ==================================================

@onready var level_label = $LevelLabel
@onready var mission_message = $MissionMessage
@onready var security_warning = $SecurityWarning


# ==================================================
# READY
# ==================================================

func _ready():

	# ==================================================
	# HIDE MISSION MESSAGE AT START
	# ==================================================

	mission_message.hide()


	# ==================================================
	# MAKE MISSION MESSAGE FULL SCREEN
	#
	# This gives the Label the entire screen as its area.
	# Then the text can be centered inside that area.
	# ==================================================

	mission_message.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


	# ==================================================
	# CENTER TEXT HORIZONTALLY
	# ==================================================

	mission_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


	# ==================================================
	# CENTER TEXT VERTICALLY
	# ==================================================

	mission_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


	# ==================================================
	# LARGE FONT
	# ==================================================

	mission_message.add_theme_font_size_override(
		"font_size",
		48
	)


	# ==================================================
	# HIDE SECURITY WARNING AT START
	# ==================================================

	security_warning.hide()


	print("HUD READY")

# ==================================================
# PROCESS
# ==================================================

func _process(_delta):

	var level_manager = get_tree().get_first_node_in_group(
		"level_manager"
	)

	if level_manager == null:
		return


	# ==================================================
	# LEVEL + BOXES + TIME
	# ==================================================

	level_label.text = "LEVEL %d\nBOXES: %d / %d\nTIME: %02d:%02d" % [

		level_manager.level_number,

		level_manager.delivered_boxes,
		level_manager.required_boxes,

		int(level_manager.time_left) / 60,
		int(level_manager.time_left) % 60
	]


	# ==================================================
	# MISSION FINISHED
	# ==================================================

	if level_manager.mission_finished:

		# ----------------------------------------------
		# MISSION PASSED
		# ----------------------------------------------

		if level_manager.delivered_boxes >= level_manager.required_boxes:

			mission_message.text = "MISSION PASSED"


		# ----------------------------------------------
		# MISSION FAILED
		# ----------------------------------------------

		else:

			mission_message.text = "MISSION FAILED"


		# Show only after mission has finished
		if not mission_message.visible:

			mission_message.show()


	# ==================================================
	# MISSION STILL RUNNING
	# ==================================================

	else:

		# Make absolutely sure it stays hidden
		mission_message.hide()


# ==================================================
# SECURITY WARNING
# ==================================================

func show_security_warning(time_left: float):

	security_warning.show()

	security_warning.text = (
		"⚠ SECURITY VEHICLE DETECTED!\n"
		+ "MOVE AWAY!  %.1f" % time_left
	)

	print("HUD: SECURITY WARNING SHOWN")


# ==================================================
# UPDATE SECURITY WARNING
# ==================================================

func update_security_warning(time_left: float):

	if not security_warning.visible:

		security_warning.show()

	security_warning.text = (
		"⚠ SECURITY VEHICLE DETECTED!\n"
		+ "MOVE AWAY!  %.1f" % time_left
	)


# ==================================================
# HIDE SECURITY WARNING
# ==================================================

func hide_security_warning():

	security_warning.hide()

	print("HUD: SECURITY WARNING HIDDEN")
