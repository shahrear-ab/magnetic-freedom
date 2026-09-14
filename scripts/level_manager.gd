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
# READY
# ==================================================

func _ready():

	print("==============================")
	print("LEVEL MANAGER READY")
	print("LEVEL: ", level_number)
	print("TIME: ", level_time)
	print("BOXES REQUIRED: ", required_boxes)
	print("==============================")

	# Save original box positions
	for box in get_tree().get_nodes_in_group("pickup_boxes"):

		box_start_positions[box] = box.global_position
		box_start_rotations[box] = box.global_rotation

	start_level()


# ==================================================
# START LEVEL
# ==================================================

func start_level():

	time_left = level_time
	delivered_boxes = 0
	level_active = true
	mission_finished = false


	# ==================================================
	# RESET DELIVERY ZONE
	# ==================================================

	var delivery_zone = get_node_or_null("../DeliveryZone/Area3D")

	if delivery_zone != null:

		delivery_zone.reset_delivery_zone()

	else:

		print("WARNING: DeliveryZone Area3D not found!")


	# ==================================================
	# RESET ALL PICKUP BOXES
	# ==================================================

	var boxes = get_tree().get_nodes_in_group("pickup_boxes")

	for i in range(boxes.size()):

		var box = boxes[i]

		# Reset position
		if box_start_positions.has(box):

			box.global_position = box_start_positions[box]


		# Reset rotation
		if box_start_rotations.has(box):

			box.global_rotation = box_start_rotations[box]


		# Show only the required number of boxes
		if i < required_boxes:

			box.show()

		else:

			box.hide()


	# ==================================================
	# PRINT LEVEL INFORMATION
	# ==================================================

	print("==============================")
	print("LEVEL ", level_number, " STARTED")
	print("TIME: ", time_left)
	print("BOXES: 0 / ", required_boxes)
	print("==============================")


# ==================================================
# TIMER
# ==================================================

func _process(delta):

	if not level_active:
		return

	if mission_finished:
		return


	# Decrease timer
	time_left -= delta


	# Prevent negative timer
	if time_left < 0.0:

		time_left = 0.0


	# Time finished
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


	print("==============================")
	print("BOX DELIVERED!")
	print("BOXES: ", delivered_boxes, " / ", required_boxes)
	print("TIME LEFT: ", time_left)
	print("==============================")


	# Check if objective completed
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
	print("BOXES DELIVERED: ", delivered_boxes)
	print("TIME REMAINING: ", time_left)
	print("==============================")
	print("")


	# If this wasn't the final level
	if level_number < total_levels:

		get_tree().create_timer(3.0).timeout.connect(start_next_level)


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


	# Start the new level
	start_level()


# ==================================================
# LEVEL FAILED
# ==================================================

func fail_level(reason: String):

	if mission_finished:
		return


	mission_finished = true
	level_active = false


	print("")
	print("==============================")
	print("MISSION FAILED!")
	print("REASON: ", reason)
	print("==============================")
	print("")
