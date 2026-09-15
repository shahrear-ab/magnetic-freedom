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

	# Hide security warning when game starts
	security_warning.hide()

	print("HUD READY")


# ==================================================
# PROCESS
# ==================================================

func _process(_delta):

	var level_manager = get_tree().get_first_node_in_group("level_manager")

	if level_manager == null:
		return


	# ==================================================
	# LEVEL
	# ==================================================

	level_label.text = "LEVEL %d" % level_manager.level_number


	# ==================================================
	# MISSION MESSAGE
	# ==================================================

	if level_manager.mission_finished:

		if level_manager.delivered_boxes >= level_manager.required_boxes:

			mission_message.text = "MISSION COMPLETE"

		else:

			mission_message.text = "MISSION FAILED"

	else:

		mission_message.text = "BOXES: %d / %d\nTIME: %02d:%02d" % [
			level_manager.delivered_boxes,
			level_manager.required_boxes,
			int(level_manager.time_left) / 60,
			int(level_manager.time_left) % 60
		]


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
