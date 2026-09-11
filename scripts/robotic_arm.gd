extends Node3D

@export var arm_speed: float = 60.0
@export var elbow_speed: float = 60.0

# Arm / shoulder limits
@export var arm_min_angle: float = -60.0
@export var arm_max_angle: float = 60.0

# Elbow limits
@export var elbow_min_angle: float = -90.0
@export var elbow_max_angle: float = 90.0


@onready var arm = $Base/Shoulder/Arm
@onready var elbow = $Base/Shoulder/Arm/Elbow

# Magnet
@onready var magnet = $Base/Shoulder/Arm/Elbow/Magnet
@onready var magnet_mesh = $Base/Shoulder/Arm/Elbow/Magnet/MagnetMesh


# Pickup states
var detected_object: Node3D = null
var picked_object: Node3D = null
var pickup_locked: bool = false


func _physics_process(delta):
	# =========================
	# ARM / SHOULDER
	# =========================
	var arm_input = Input.get_axis("arm_up", "arm_down")

	if arm_input != 0:
		arm.rotation_degrees.x += arm_input * arm_speed * delta

		arm.rotation_degrees.x = clamp(
			arm.rotation_degrees.x,
			arm_min_angle,
			arm_max_angle
		)


	# =========================
	# ELBOW
	# =========================

	var elbow_input = Input.get_axis("elbow_up", "elbow_down")

	if elbow_input != 0:
		elbow.rotation_degrees.x += elbow_input * elbow_speed * delta

		elbow.rotation_degrees.x = clamp(
			elbow.rotation_degrees.x,
			elbow_min_angle,
			elbow_max_angle
		)


	# =========================
	# MAGNET
	# =========================

	if Input.is_action_just_pressed("magnet"):
		toggle_magnet()


	# =========================
	# KEEP OBJECT ATTACHED
	# =========================

	if picked_object != null:
		picked_object.global_position = magnet_mesh.global_position
		picked_object.global_rotation = magnet.global_rotation


# ==================================================
# OBJECT ENTERS MAGNET AREA
# ==================================================

func _on_magnet_aera_body_entered(body: Node3D) -> void:
	if picked_object != null:
		return

	if pickup_locked:
		return

	print("MAGNET DETECTED: ", body.name)

	detected_object = body


func _on_magnet_aera_body_exited(body: Node3D) -> void:
	if body == detected_object:
		detected_object = null

		print("MAGNET LOST: ", body.name)


# ==================================================
# PICKUP / RELEASE
# ==================================================

func toggle_magnet():

	# ==================================================
	# RELEASE
	# ==================================================

	if picked_object != null:

		print("MAGNET RELEASED: ", picked_object.name)

		var object = picked_object

		picked_object = null
		detected_object = null

		# Lock pickup temporarily
		pickup_locked = true

		object.reparent(get_tree().current_scene, true)

		object.global_position = magnet.global_position
		object.global_rotation = magnet.global_rotation

		if object is RigidBody3D:
			object.freeze = false

		# Wait for physics to update
		await get_tree().physics_frame

		pickup_locked = false

		return


	# ==================================================
	# PICKUP
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

		# Attach to magnet
		object.reparent(magnet, true)

		# Snap to magnet
		object.global_position = magnet_mesh.global_position
		object.global_rotation = magnet.global_rotation

		print("OBJECT ATTACHED TO MAGNET")

	else:

		print("NO OBJECT IN MAGNET RANGE")
