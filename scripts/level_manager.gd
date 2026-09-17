extends Node


# ==================================================
# LEVEL SETTINGS
# ==================================================

@export var level_number: int = 1
@export var level_time: float = 180.0
@export var required_boxes: int = 1

@export var total_levels: int = 5


# ==================================================
# BOX STARTING POSITIONS
# ==================================================

var box_start_positions: Dictionary = {}
var box_start_rotations: Dictionary = {}


# ==================================================
# CURRENT STATE
# ==================================================

var time_left: float = 0.0
var delivered_boxes: int = 0

var level_active: bool = false
var mission_finished: bool = false


# ==================================================
# TIMER WARNING STATE
# ==================================================
#
# Prevents timer_warning.ogg from playing repeatedly.
#

var timer_warning_played: bool = false


# ==================================================
# REFERENCES
# ==================================================

@onready var pause_menu = $"../HUD/PauseMenu"


# ==================================================
# READY
# ==================================================

func _ready():

	print("==============================")
	print("LEVEL MANAGER READY")
	print("LEVEL: ", level_number)
	print("TIME: ", level_time)
	print("BOXES REQUIRED: ", required_boxes)
	print("==============================")


	# ==================================================
	# SAVE ORIGINAL BOX POSITIONS
	# ==================================================

	for box in get_tree().get_nodes_in_group("pickup_boxes"):

		box_start_positions[box] = box.global_position
		box_start_rotations[box] = box.global_rotation


	# ==================================================
	# START LEVEL
	# ==================================================



# ==================================================
# START LEVEL
# ==================================================

func start_level():

	time_left = level_time
	delivered_boxes = 0

	level_active = true
	mission_finished = false

	# Reset 30-second warning
	timer_warning_played = false


	# ==================================================
	# RESET DELIVERY ZONE
	# ==================================================

	var delivery_zone = get_node_or_null(
		"../DeliveryZone/Area3D"
	)

	if delivery_zone != null:

		delivery_zone.reset_delivery_zone()

	else:

		print(
			"WARNING: DeliveryZone Area3D not found!"
		)


	# ==================================================
	# RESET ALL PICKUP BOXES
	# ==================================================

	var boxes = get_tree().get_nodes_in_group(
		"pickup_boxes"
	)


	for i in range(boxes.size()):

		var box = boxes[i]


		# ==================================================
		# RESET POSITION
		# ==================================================

		if box_start_positions.has(box):

			box.global_position = (
				box_start_positions[box]
			)


		# ==================================================
		# RESET ROTATION
		# ==================================================

		if box_start_rotations.has(box):

			box.global_rotation = (
				box_start_rotations[box]
			)


		# ==================================================
		# SHOW / HIDE BOXES + COLLISION
		# ==================================================

		if i < required_boxes:
			
			# Required box
			box.show()
			

		else:

			# Unrequired box
			box.hide()
			



	# ==================================================
	# PRINT LEVEL INFORMATION
	# ==================================================

	print("==============================")
	print("LEVEL ", level_number, " STARTED")
	print("TIME: ", time_left)
	print(
		"BOXES: 0 / ",
		required_boxes
	)
	print("==============================")


# ==================================================
# TIMER
# ==================================================

func _process(delta):

	if not level_active:

		return


	if mission_finished:

		return


	# ==================================================
	# DECREASE TIMER
	# ==================================================

	time_left -= delta


	# ==================================================
	# 30 SECOND WARNING
	# ==================================================

	if time_left <= 30.0:

		if not timer_warning_played:

			timer_warning_played = true

			AudioManager.play_timer_warning()

			print("==============================")
			print("TIMER WARNING!")
			print("30 SECONDS REMAINING!")
			print("==============================")


	# ==================================================
	# PREVENT NEGATIVE TIMER
	# ==================================================

	if time_left < 0.0:

		time_left = 0.0


	# ==================================================
	# TIME FINISHED
	# ==================================================

	if time_left <= 0.0:

		fail_level("TIME UP")


# ==================================================
# BOX DELIVERED
# ==================================================

func box_delivered():

	if not level_active:

		return


	if mission_finished:

		return


	delivered_boxes += 1


	# ==================================================
	# BOX DELIVERED SOUND
	# ==================================================

	AudioManager.play_box_delivered()


	print("==============================")
	print("BOX DELIVERED!")
	print(
		"BOXES: ",
		delivered_boxes,
		" / ",
		required_boxes
	)
	print("TIME LEFT: ", time_left)
	print("==============================")


	# ==================================================
	# CHECK OBJECTIVE
	# ==================================================

	if delivered_boxes >= required_boxes:

		complete_level()


# ==================================================
# LEVEL COMPLETE
# ==================================================

func complete_level():

	if mission_finished:

		return


	mission_finished = true
	level_active = false


	print("")
	print("==============================")
	print("MISSION COMPLETE!")
	print("LEVEL ", level_number, " COMPLETE")
	print(
		"BOXES DELIVERED: ",
		delivered_boxes
	)
	print(
		"TIME REMAINING: ",
		time_left
	)
	print("==============================")
	print("")


	# ==================================================
	# FINAL LEVEL
	# ==================================================
	#
	# LEVEL 5:
	#
	# Play ONLY level_complete.ogg
	#
	# Do NOT play mission_complete.ogg.
	# ==================================================

	if level_number >= total_levels:

		print("==============================")
		print("ALL MISSIONS COMPLETED!")
		print("==============================")


		# 🔊 FINAL VICTORY SOUND

		AudioManager.play_level_complete()


		# Show final screen

		pause_menu.show_all_missions_complete()

		return


	# ==================================================
	# NORMAL LEVEL COMPLETE
	# ==================================================
	#
	# Levels 1–4:
	#
	# Play mission_complete.ogg
	# ==================================================

	AudioManager.play_mission_complete()


	# ==================================================
	# WAIT BEFORE NEXT LEVEL
	# ==================================================

	get_tree().create_timer(3.0).timeout.connect(
		start_next_level
	)


# ==================================================
# START NEXT LEVEL
# ==================================================

func start_next_level():

	level_number += 1


	# ==================================================
	# LEVEL SETTINGS
	# ==================================================

	match level_number:

		2:

			level_time = 150.0
			required_boxes = 2


		3:

			level_time = 140.0
			required_boxes = 2


		4:

			level_time = 120.0
			required_boxes = 3


		5:

			level_time = 100.0
			required_boxes = 3


	# ==================================================
	# START NEW LEVEL
	# ==================================================

	start_level()


# ==================================================
# LEVEL FAILED
# ==================================================

func fail_level(reason: String):

	if mission_finished:

		return


	mission_finished = true
	level_active = false


	# ==================================================
	# MISSION FAILED SOUND
	# ==================================================

	AudioManager.play_mission_failed()


	print("")
	print("==============================")
	print("MISSION FAILED!")
	print("LEVEL: ", level_number)
	print("REASON: ", reason)
	print("==============================")
	print("")


	# ==================================================
	# SHOW MISSION FAILED SCREEN
	# ==================================================

	pause_menu.show_mission_failed()
