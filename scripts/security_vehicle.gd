extends CharacterBody3D


# ==================================================
# SECURITY VEHICLE MOVEMENT
# ==================================================

@export var move_speed: float = 3.0
@export var move_distance: float = 14.0


# ==================================================
# MOVEMENT STATE
# ==================================================

var start_position: Vector3
var moving_forward: bool = true

# Security detection pause
var is_paused: bool = false


# ==================================================
# READY
# ==================================================

func _ready():

	# Remember where the security vehicle starts
	start_position = global_position

	print("==============================")
	print("SECURITY VEHICLE READY")
	print("SPEED: ", move_speed)
	print("DISTANCE: ", move_distance)
	print("==============================")


# ==================================================
# PHYSICS PROCESS
# ==================================================

func _physics_process(delta):

	# ----------------------------------------------
	# STOP WHEN PLAYER IS DETECTED
	# ----------------------------------------------

	if is_paused:
		velocity = Vector3.ZERO
		return


	# ----------------------------------------------
	# NORMAL PATROL MOVEMENT
	# ----------------------------------------------

	var forward_direction = -global_transform.basis.z.normalized()


	if moving_forward:

		global_position += forward_direction * move_speed * delta

		# Reached forward patrol limit
		if global_position.distance_to(start_position) >= move_distance:

			moving_forward = false


	else:

		global_position -= forward_direction * move_speed * delta

		# Returned to starting point
		if global_position.distance_to(start_position) <= 0.1:

			global_position = start_position
			moving_forward = true


# ==================================================
# PAUSE SECURITY VEHICLE
# ==================================================

func pause_vehicle():

	if is_paused:
		return

	is_paused = true

	velocity = Vector3.ZERO

	print("==============================")
	print("SECURITY VEHICLE PAUSED")
	print("REASON: PLAYER DETECTED")
	print("==============================")


# ==================================================
# RESUME SECURITY VEHICLE
# ==================================================

func resume_vehicle():

	if not is_paused:
		return

	is_paused = false

	print("==============================")
	print("SECURITY VEHICLE RESUMED")
	print("==============================")
