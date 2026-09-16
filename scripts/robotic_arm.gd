extends Node3D


# ==================================================
# ARM SETTINGS
# ==================================================

@export var arm_speed: float = 60.0
@export var elbow_speed: float = 60.0

@export var arm_min_angle: float = -65.0
@export var arm_max_angle: float = 65.0

@export var elbow_min_angle: float = -90.0
@export var elbow_max_angle: float = 90.0


# ==================================================
# MAGNET MOVEMENT SETTINGS
# ==================================================

@export var magnet_move_speed: float = 60.0

@export var magnet_min_x: float = -60.0
@export var magnet_max_x: float = 60.0

@export var magnet_min_y: float = -60.0
@export var magnet_max_y: float = 60.0


# ==================================================
# PICKUP SETTINGS
# ==================================================

@export var pickup_distance: float = 1.0


# ==================================================
# ANGULAR ALIGNMENT
# ==================================================

@export var magnet_alignment_tolerance: float = 15.0


# ==================================================
# MAGNET VISUAL / ALIGNMENT SETTINGS
# ==================================================

const ARM_MAGNET_HEIGHT: float = 0.12
const BOX_MAGNET_HEIGHT: float = 0.08
const MAGNET_GAP: float = 0.02


# ==================================================
# ARM REFERENCES
# ==================================================

@onready var arm = $Base/Shoulder/Arm

@onready var elbow = (
	$Base/Shoulder/Arm/Elbow
)


# ==================================================
# ARM MAGNET REFERENCES
# ==================================================

@onready var magnet_pivot = (
	$Base/Shoulder/Arm/Elbow/MagnetPivot
)

@onready var magnet = (
	$Base/Shoulder/Arm/Elbow/MagnetPivot/Magnet
)

@onready var magnet_mesh = (
	$Base/Shoulder/Arm/Elbow/MagnetPivot/Magnet/MagnetMesh
)


# ==================================================
# ARM COLLISION DETECTORS
# ==================================================

@onready var arm_collision_detector = (
	$Base/Shoulder/Arm/ArmCollisionDetector
)

@onready var forearm_collision_detector = (
	$Base/Shoulder/Arm/Elbow/ForearmCollisionDetector
)


# ==================================================
# PICKUP STATE
# ==================================================

var picked_object: Node3D = null


# ==================================================
# SAVED COLLISION SETTINGS
# ==================================================
#
# Each picked object gets its own saved collision
# settings.
#
# This is safer than having only one global
# collision_layer / collision_mask pair.
#
# ==================================================

var saved_collision_settings: Dictionary = {}


# ==================================================
# READY
# ==================================================

func _ready():

	print("================================")
	print("ROBOTIC ARM READY")
	print("================================")

	arm_collision_detector.monitoring = true
	forearm_collision_detector.monitoring = true


# ==================================================
# PHYSICS PROCESS
# ==================================================

func _physics_process(delta):


	# ==================================================
	# ARM MOVEMENT
	# ==================================================

	var arm_input = Input.get_axis(
		"arm_up",
		"arm_down"
	)

	if arm_input != 0:

		var old_rotation = arm.rotation_degrees.x

		arm.rotation_degrees.x += (
			arm_input
			* arm_speed
			* delta
		)

		arm.rotation_degrees.x = clamp(
			arm.rotation_degrees.x,
			arm_min_angle,
			arm_max_angle
		)

		# Check collision

		if arm_collision_detector.has_overlapping_bodies():

			arm.rotation_degrees.x = old_rotation

			print("ARM BLOCKED!")


	# ==================================================
	# ELBOW MOVEMENT
	# ==================================================

	var elbow_input = Input.get_axis(
		"elbow_up",
		"elbow_down"
	)

	if elbow_input != 0:

		var old_rotation = elbow.rotation_degrees.x

		elbow.rotation_degrees.x += (
			elbow_input
			* elbow_speed
			* delta
		)

		elbow.rotation_degrees.x = clamp(
			elbow.rotation_degrees.x,
			elbow_min_angle,
			elbow_max_angle
		)

		# Check collision

		if forearm_collision_detector.has_overlapping_bodies():

			elbow.rotation_degrees.x = old_rotation

			print("FOREARM BLOCKED!")


	# ==================================================
	# MAGNET PICKUP / RELEASE
	#
	# SPACE
	# ==================================================

	if Input.is_action_just_pressed("magnet"):

		toggle_magnet()


	# ==================================================
	# MAGNET CONTROL
	#
	# HOLD M
	# ==================================================

	if Input.is_key_pressed(KEY_M):

		control_magnet(delta)


	# ==================================================
	# KEEP PICKED OBJECT ATTACHED
	# ==================================================

	if picked_object != null:

		if is_instance_valid(picked_object):

			align_picked_object()

		else:

			picked_object = null


# ==================================================
# MAGNET MOVEMENT
# ==================================================

func control_magnet(delta):


	# ==================================================
	# W / S
	# ==================================================

	var forward_input = Input.get_axis(
		"move_backward",
		"move_forward"
	)


	# ==================================================
	# A / D
	# ==================================================

	var side_input = Input.get_axis(
		"turn_left",
		"turn_right"
	)


	# ==================================================
	# MAGNET X ROTATION
	# ==================================================

	if forward_input != 0:

		magnet_pivot.rotation_degrees.x += (
			forward_input
			* magnet_move_speed
			* delta
		)

		magnet_pivot.rotation_degrees.x = clamp(
			magnet_pivot.rotation_degrees.x,
			magnet_min_x,
			magnet_max_x
		)


	# ==================================================
	# MAGNET Y ROTATION
	# ==================================================

	if side_input != 0:

		magnet_pivot.rotation_degrees.y += (
			side_input
			* magnet_move_speed
			* delta
		)

		magnet_pivot.rotation_degrees.y = clamp(
			magnet_pivot.rotation_degrees.y,
			magnet_min_y,
			magnet_max_y
		)


# ==================================================
# GET OBJECT MAGNET POINT
# ==================================================

func get_object_magnet_point(
	object: Node3D
) -> Node3D:

	if object == null:

		return null


	var magnet_point = object.get_node_or_null(
		"MagnetPoint"
	)


	if magnet_point != null:

		return magnet_point


	return null


# ==================================================
# CALCULATE MAGNET ALIGNMENT
# ==================================================

func get_magnet_alignment_angle(
	object_magnet: Node3D
) -> float:

	if object_magnet == null:

		return 180.0


	# ==================================================
	# ARM MAGNET AXIS
	# ==================================================

	var arm_axis = (
		magnet.global_transform.basis.y.normalized()
	)


	# ==================================================
	# BOX MAGNET AXIS
	# ==================================================

	var box_axis = (
		object_magnet.global_transform.basis.y.normalized()
	)


	# ==================================================
	# DOT PRODUCT
	# ==================================================

	var alignment = abs(
		arm_axis.dot(box_axis)
	)

	alignment = clamp(
		alignment,
		-1.0,
		1.0
	)


	# ==================================================
	# ANGLE
	# ==================================================

	var angle = rad_to_deg(
		acos(alignment)
	)


	return angle


# ==================================================
# FIND VALID PICKUP OBJECT
# ==================================================

func find_closest_magnetic_object() -> Node3D:

	var best_object: Node3D = null

	var best_distance: float = pickup_distance


	var objects = get_tree().get_nodes_in_group(
		"pickupable"
	)


	for object in objects:

		# ==================================================
		# VALID OBJECT
		# ==================================================

		if not is_instance_valid(object):

			continue


		# ==================================================
		# IGNORE CURRENT OBJECT
		# ==================================================

		if object == picked_object:

			continue


		# ==================================================
		# MUST BE NODE3D
		# ==================================================

		if not object is Node3D:

			continue


		var object_3d: Node3D = object


		# ==================================================
		# GET MAGNET POINT
		# ==================================================

		var object_magnet = (
			get_object_magnet_point(
				object_3d
			)
		)


		if object_magnet == null:

			continue


		# ==================================================
		# DISTANCE CHECK
		# ==================================================

		var distance = (
			magnet.global_position.distance_to(
				object_magnet.global_position
			)
		)


		if distance > pickup_distance:

			continue


		# ==================================================
		# ALIGNMENT CHECK
		# ==================================================

		var angle = (
			get_magnet_alignment_angle(
				object_magnet
			)
		)


		if angle > magnet_alignment_tolerance:

			continue


		# ==================================================
		# CLOSEST VALID OBJECT
		# ==================================================

		if distance < best_distance:

			best_distance = distance

			best_object = object_3d


	return best_object


# ==================================================
# GET MAGNET CONTACT TRANSFORM
# ==================================================

func get_magnet_contact_transform() -> Transform3D:

	var contact_transform = (
		magnet.global_transform
	)


	# ==================================================
	# MAGNET CENTER DISTANCE
	# ==================================================

	var center_distance = (
		ARM_MAGNET_HEIGHT / 2.0
		+ BOX_MAGNET_HEIGHT / 2.0
		+ MAGNET_GAP
	)


	# ==================================================
	# MOVE TO BOTTOM OF ARM MAGNET
	# ==================================================

	contact_transform.origin += (
		-magnet.global_transform.basis.y.normalized()
		* center_distance
	)


	# ==================================================
	# FLIP BOX MAGNET
	# ==================================================

	contact_transform.basis = (
		contact_transform.basis
		* Basis(
			Vector3.RIGHT,
			PI
		)
	)


	return contact_transform


# ==================================================
# ALIGN PICKED OBJECT
# ==================================================

func align_picked_object():

	if picked_object == null:

		return


	if not is_instance_valid(picked_object):

		picked_object = null

		return


	# ==================================================
	# GET OBJECT MAGNET
	# ==================================================

	var object_magnet = (
		get_object_magnet_point(
			picked_object
		)
	)


	if object_magnet == null:

		return


	# ==================================================
	# TARGET TRANSFORM
	# ==================================================

	var target_transform = (
		get_magnet_contact_transform()
	)


	# ==================================================
	# CALCULATE WHOLE OBJECT TRANSFORM
	# ==================================================

	var box_transform = (
		target_transform
		* object_magnet.transform.affine_inverse()
	)


	# ==================================================
	# APPLY TRANSFORM
	# ==================================================

	picked_object.global_transform = (
		box_transform
	)


# ==================================================
# MAGNET TOGGLE
# ==================================================

func toggle_magnet():

	# ==================================================
	# ALREADY HOLDING OBJECT
	# ==================================================

	if picked_object != null:

		release_object()

		return


	# ==================================================
	# FIND OBJECT
	# ==================================================

	var object = (
		find_closest_magnetic_object()
	)


	# ==================================================
	# NOTHING FOUND
	# ==================================================

	if object == null:

		print(
			"CANNOT PICK UP - "
			+ "BOX NOT CLOSE AND ALIGNED"
		)

		return


	# ==================================================
	# PICKUP
	# ==================================================

	pickup_object(object)


# ==================================================
# PICKUP OBJECT
# ==================================================

func pickup_object(
	object: Node3D
):

	if object == null:

		return


	# ==================================================
	# GET MAGNET POINT
	# ==================================================

	var object_magnet = (
		get_object_magnet_point(
			object
		)
	)


	if object_magnet == null:

		print(
			"CANNOT PICK UP - "
			+ "BOX HAS NO MAGNETPOINT"
		)

		return


	print("================================")
	print("MAGNET PICKED UP: ", object.name)
	print("================================")


	# ==================================================
	# GET TARGET TRANSFORM
	# ==================================================

	var target_transform = (
		get_magnet_contact_transform()
	)


	# ==================================================
	# CALCULATE OBJECT TRANSFORM
	# ==================================================

	var desired_box_transform = (
		target_transform
		* object_magnet.transform.affine_inverse()
	)


	# ==================================================
	# SAVE PHYSICS SETTINGS
	# ==================================================

	if object is RigidBody3D:

		var rigid_body := object as RigidBody3D


		# Save collision settings specifically
		# for this object.

		saved_collision_settings[object] = {
			"layer": rigid_body.collision_layer,
			"mask": rigid_body.collision_mask
		}


		# ==================================================
		# STOP PHYSICS
		# ==================================================

		rigid_body.freeze = true

		rigid_body.linear_velocity = Vector3.ZERO
		rigid_body.angular_velocity = Vector3.ZERO


		# ==================================================
		# DISABLE COLLISION WHILE CARRIED
		# ==================================================

		rigid_body.collision_layer = 0
		rigid_body.collision_mask = 0


	# ==================================================
	# ATTACH OBJECT TO MAGNET
	# ==================================================

	object.reparent(
		magnet,
		true
	)


	# ==================================================
	# APPLY POSITION + ROTATION
	# ==================================================

	object.global_transform = (
		desired_box_transform
	)


	# ==================================================
	# SAVE PICKUP STATE
	# ==================================================

	picked_object = object


	# 🔊 MAGNET ATTACH SOUND
	AudioManager.play_magnet()
	
	print("OBJECT ATTACHED TO MAGNET")


# ==================================================
# RELEASE OBJECT
# ==================================================

func release_object():

	if picked_object == null:

		return


	if not is_instance_valid(picked_object):

		picked_object = null

		return


	var object = picked_object


	print("================================")
	print("MAGNET RELEASED: ", object.name)
	print("================================")


	# ==================================================
	# CLEAR PICKUP STATE FIRST
	# ==================================================

	picked_object = null


	# ==================================================
	# SAVE WORLD TRANSFORM
	# ==================================================

	var release_transform = (
		object.global_transform
	)


	# ==================================================
	# REMOVE FROM MAGNET
	# ==================================================

	object.reparent(
		get_tree().current_scene,
		true
	)


	# ==================================================
	# RESTORE WORLD TRANSFORM
	# ==================================================

	object.global_transform = (
		release_transform
	)


	# ==================================================
	# RESTORE PHYSICS
	# ==================================================

	if object is RigidBody3D:

		var rigid_body := object as RigidBody3D


		# ==================================================
		# RESTORE COLLISION SETTINGS
		# ==================================================

		if saved_collision_settings.has(object):

			var settings = (
				saved_collision_settings[object]
			)

			rigid_body.collision_layer = (
				settings["layer"]
			)

			rigid_body.collision_mask = (
				settings["mask"]
			)


		# ==================================================
		# UNFREEZE
		# ==================================================

		rigid_body.freeze = false


		# ==================================================
		# RESET VELOCITY
		# ==================================================

		rigid_body.linear_velocity = Vector3.ZERO
		rigid_body.angular_velocity = Vector3.ZERO


		# ==================================================
		# REMOVE SAVED SETTINGS
		# ==================================================

		saved_collision_settings.erase(object)


	# 🔊 MAGNET RELEASE SOUND
	AudioManager.play_magnet()
	
	print("OBJECT RELEASED")
