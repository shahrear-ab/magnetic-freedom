extends Node3D


# ==================================================
# ARM SETTINGS
# ==================================================

@export var arm_speed: float = 60.0
@export var elbow_speed: float = 60.0


# Arm / shoulder limits
@export var arm_min_angle: float = -60.0
@export var arm_max_angle: float = 60.0


# Elbow limits
@export var elbow_min_angle: float = -90.0
@export var elbow_max_angle: float = 90.0


# ==================================================
# ARM REFERENCES
# ==================================================

@onready var arm = $Base/Shoulder/Arm
@onready var elbow = $Base/Shoulder/Arm/Elbow


# ==================================================
# MAGNET REFERENCES
# ==================================================

@onready var magnet = $Base/Shoulder/Arm/Elbow/Magnet
@onready var magnet_mesh = $Base/Shoulder/Arm/Elbow/Magnet/MagnetMesh


# ==================================================
# MAGNET AREA
# ==================================================

@onready var magnet_area = $Base/Shoulder/Arm/Elbow/Magnet/MagnetAera


# ==================================================
# ARM COLLISION DETECTORS
# ==================================================

@onready var arm_collision_detector = $Base/Shoulder/Arm/ArmCollisionDetector
@onready var forearm_collision_detector = $Base/Shoulder/Arm/Elbow/ForearmCollisionDetector

# ==================================================
# COLLISION STATES
# ==================================================

var arm_blocked: bool = false
var forearm_blocked: bool = false


# ==================================================
# PICKUP STATES
# ==================================================

var detected_object: Node3D = null
var picked_object: Node3D = null
var pickup_locked: bool = false


# ==================================================
# READY
# ==================================================

func _ready():

	print("ROBOTIC ARM READY")

	# Make sure our collision detectors are monitoring
	arm_collision_detector.monitoring = true
	forearm_collision_detector.monitoring = true


# ==================================================
# PHYSICS PROCESS
# ==================================================

func _physics_process(delta):

	# =========================
	# ARM / SHOULDER
	# =========================

	var arm_input = Input.get_axis("arm_up", "arm_down")

	if arm_input != 0:

		var old_rotation = arm.rotation_degrees.x

		arm.rotation_degrees.x += arm_input * arm_speed * delta

		arm.rotation_degrees.x = clamp(
			arm.rotation_degrees.x,
			arm_min_angle,
			arm_max_angle
		)

		# Check collision
		if arm_collision_detector.has_overlapping_bodies():
			arm.rotation_degrees.x = old_rotation
			print("ARM BLOCKED!")


	# =========================
	# ELBOW
	# =========================

	var elbow_input = Input.get_axis("elbow_up", "elbow_down")

	if elbow_input != 0:

		var old_rotation = elbow.rotation_degrees.x

		elbow.rotation_degrees.x += elbow_input * elbow_speed * delta

		elbow.rotation_degrees.x = clamp(
			elbow.rotation_degrees.x,
			elbow_min_angle,
			elbow_max_angle
		)

		# Check collision
		if forearm_collision_detector.has_overlapping_bodies():
			elbow.rotation_degrees.x = old_rotation
			print("FOREARM BLOCKED!")


	# =========================
	# MAGNET
	# =========================

	if Input.is_action_just_pressed("magnet"):
		toggle_magnet()


	# =========================
	# KEEP PICKED OBJECT ATTACHED
	# =========================

	if picked_object != null:
		picked_object.global_position = magnet_mesh.global_position
		picked_object.global_rotation = magnet.global_rotation

# ==================================================
# MAGNET AREA - OBJECT ENTERED
# ==================================================

func _on_magnet_aera_body_entered(body: Node3D) -> void:

	# Ignore anything that isn't pickupable
	if not body.is_in_group("pickupable"):
		return

	# Already holding something
	if picked_object != null:
		return

	# Temporarily locked after release
	if pickup_locked:
		return

	print("MAGNET DETECTED: ", body.name)

	detected_object = body


# ==================================================
# MAGNET AREA - OBJECT EXITED
# ==================================================

func _on_magnet_aera_body_exited(body: Node3D) -> void:

	if body == detected_object:

		detected_object = null

		print("MAGNET LOST: ", body.name)


# ==================================================
# MAGNET TOGGLE
# ==================================================

func toggle_magnet():


	# ==================================================
	# RELEASE OBJECT
	# ==================================================

	if picked_object != null:

		print("MAGNET RELEASED: ", picked_object.name)

		var object = picked_object

		picked_object = null
		detected_object = null

		# Prevent instant re-pickup
		pickup_locked = true


		# Remove from magnet
		object.reparent(get_tree().current_scene, true)


		# Drop at magnet position
		object.global_position = magnet.global_position
		object.global_rotation = magnet.global_rotation


		# Restore physics
		if object is RigidBody3D:

			object.freeze = false
			object.linear_velocity = Vector3.ZERO
			object.angular_velocity = Vector3.ZERO


		# Wait one physics frame
		await get_tree().physics_frame


		pickup_locked = false

		return


	# ==================================================
	# PICKUP OBJECT
	# ==================================================

	if detected_object != null:

		var object = detected_object

		print("MAGNET PICKED UP: ", object.name)


		# Save object
		picked_object = object
		detected_object = null


		# Stop physics
		if object is RigidBody3D:

			object.freeze = true

			object.linear_velocity = Vector3.ZERO
			object.angular_velocity = Vector3.ZERO


		# Attach object to magnet
		object.reparent(magnet, true)


		# Snap object to magnet
		object.global_position = magnet_mesh.global_position
		object.global_rotation = magnet.global_rotation


		print("OBJECT ATTACHED TO MAGNET")


	# ==================================================
	# NOTHING TO PICK UP
	# ==================================================

	else:

		print("NO OBJECT IN MAGNET RANGE")
