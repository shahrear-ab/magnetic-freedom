extends CharacterBody3D


@export var move_speed := 8.0
@export var turn_speed := 2.5


func _physics_process(delta):

	# ==================================================
	# M HELD = ROBOTIC ARM CONTROLS W/A/S/D
	# ==================================================

	if Input.is_key_pressed(KEY_M):

		velocity = Vector3.ZERO

		# Stop engine while controlling the arm
		AudioManager.stop_engine()

		move_and_slide()

		return


	# ==================================================
	# NORMAL VEHICLE CONTROLS
	# ==================================================

	var forward_input = Input.get_axis(
		"move_backward",
		"move_forward"
	)

	var turn_input = Input.get_axis(
		"turn_left",
		"turn_right"
	)


	# ==================================================
	# ENGINE SOUND
	# ==================================================

	if forward_input != 0:

		AudioManager.start_engine()

	else:

		AudioManager.stop_engine()


	# ==================================================
	# DEBUG
	# ==================================================

	if forward_input != 0:

		print(
			"FORWARD INPUT: ",
			forward_input
		)


	if turn_input != 0:

		print(
			"TURN INPUT: ",
			turn_input
		)


	# ==================================================
	# VEHICLE MOVEMENT
	# ==================================================

	var forward_direction = -transform.basis.z

	velocity = (
		forward_direction
		* forward_input
		* move_speed
	)


	# ==================================================
	# VEHICLE TURNING
	# ==================================================

	rotate_y(
		-turn_input
		* turn_speed
		* delta
	)


	move_and_slide()
