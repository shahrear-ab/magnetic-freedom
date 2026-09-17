extends Node


# ==================================================
# LEVEL SETTINGS
# ==================================================

@export var level_number: int = 1
@export var level_time: float = 180.0
@export var required_boxes: int = 1

@export var total_levels: int = 5

const BOX_IDS: Array[String] = [
	"PickupObject",
	"PickupObject2",
	"PickupObject3"
]


# ==================================================
# BOX STARTING POSITIONS
# ==================================================

var box_start_positions: Dictionary = {}
var box_start_rotations: Dictionary = {}
var boxes_by_id: Dictionary = {}


# ==================================================
# PLAYER VEHICLE STARTING TRANSFORM
# ==================================================

var player_original_position: Vector3 = Vector3.ZERO
var player_original_rotation: Vector3 = Vector3.ZERO


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

	if get_tree().has_meta("restarting_level_number"):

		level_number = int(
			get_tree().get_meta("restarting_level_number")
		)
		get_tree().remove_meta("restarting_level_number")

		_apply_level_settings()

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

		boxes_by_id[box.name] = box
		box_start_positions[box] = box.global_position
		box_start_rotations[box] = box.global_rotation


	# ==================================================
	# SAVE ORIGINAL PLAYER VEHICLE TRANSFORM
	# ==================================================

	var player_vehicle = get_tree().get_first_node_in_group(
		"player_vehicle"
	)

	if player_vehicle != null:

		player_original_position = player_vehicle.global_position
		player_original_rotation = player_vehicle.global_rotation

		print("PLAYER VEHICLE STARTING POSITION: ", player_original_position)
		print("PLAYER VEHICLE STARTING ROTATION: ", player_original_rotation)

	else:

		print("WARNING: Player vehicle not found in player_vehicle group!")


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

	for i in range(BOX_IDS.size()):

		var box = boxes_by_id.get(BOX_IDS[i]) as Node3D

		if box == null or not is_instance_valid(box):

			print("WARNING: Pickup box not found: ", BOX_IDS[i])
			continue


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
		# Activate boxes by stable identity, never group-array order.
		# ==================================================

		var box_is_active = i < required_boxes

		if box_is_active:

			box.show()
			box.add_to_group("pickupable")

		else:

			box.hide()
			box.remove_from_group("pickupable")


		if box is RigidBody3D:

			var rigid_body := box as RigidBody3D

			rigid_body.freeze = true
			rigid_body.linear_velocity = Vector3.ZERO
			rigid_body.angular_velocity = Vector3.ZERO

			var collision_shape = box.get_node_or_null(
				"CollisionShape3D"
			) as CollisionShape3D

			if collision_shape != null:

				collision_shape.disabled = not box_is_active

			rigid_body.freeze = not box_is_active


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
	AudioManager.stop_engine()
	AudioManager.stop_security_detect()


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
	_apply_level_settings()


	# ==================================================
	# START NEW LEVEL
	# ==================================================

	start_level()


# ==================================================
# APPLY LEVEL SETTINGS
# ==================================================

func _apply_level_settings():

	match level_number:

		1:

			level_time = 180.0
			required_boxes = 1

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
# LEVEL FAILED
# ==================================================

func fail_level(reason: String):

	if mission_finished:

		return


	mission_finished = true
	level_active = false
	AudioManager.stop_engine()
	AudioManager.stop_security_detect()


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


# ==================================================
# RESET TO LEVEL 1
# ==================================================

func reset_to_level_one():

	print("")
	print("==============================")
	print("RESETTING TO LEVEL 1")
	print("==============================")
	print("")


	# ==================================================
	# RESET LEVEL NUMBER
	# ==================================================

	level_number = 1


	# ==================================================
	# APPLY LEVEL 1 SETTINGS
	# ==================================================

	_apply_level_settings()


	# ==================================================
	# RESET STATE
	# ==================================================

	time_left = 0.0
	delivered_boxes = 0
	level_active = false
	mission_finished = false
	timer_warning_played = false


	# ==================================================
	# RESET PLAYER VEHICLE TO ORIGINAL POSITION
	# ==================================================

	var player_vehicle = get_tree().get_first_node_in_group(
		"player_vehicle"
	)

	if player_vehicle != null:

		print("RESETTING PLAYER VEHICLE TRANSFORM")

		# Reset position
		player_vehicle.global_position = player_original_position

		# Reset rotation
		player_vehicle.global_rotation = player_original_rotation

		# Reset velocity if it's a physics body
		if player_vehicle.has_method("set_velocity") or "velocity" in player_vehicle:

			player_vehicle.velocity = Vector3.ZERO

			print("PLAYER VELOCITY RESET")

	else:

		print("WARNING: Player vehicle not found when resetting to Level 1!")


	# ==================================================
	# START LEVEL 1
	# ==================================================

	start_level()


	print("==============================")
	print("LEVEL 1 STARTED")
	print("==============================")
	print("")
