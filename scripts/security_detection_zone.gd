extends Area3D


# ==================================================
# SECURITY DETECTION SETTINGS
# ==================================================

@export var detection_time: float = 2.0

var player_detected: bool = false
var detection_timer: float = 0.0


# ==================================================
# REFERENCES
# ==================================================

@onready var security_vehicle = get_parent()
@onready var hud = get_node("../../HUD")


# ==================================================
# READY
# ==================================================

func _ready():

	print("SECURITY DETECTION ZONE READY")

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


# ==================================================
# PLAYER ENTERS DETECTION ZONE
# ==================================================

func _on_body_entered(body: Node3D) -> void:

	if not body.is_in_group("player_vehicle"):
		return

	if player_detected:
		return

	player_detected = true
	detection_timer = detection_time


	# ==================================================
	# 🔊 SECURITY DETECTION SOUND
	# ==================================================

	AudioManager.play_security_detect()


	# ==================================================
	# STOP SECURITY VEHICLE
	# ==================================================

	if security_vehicle.has_method("pause_vehicle"):
		security_vehicle.pause_vehicle()


	# ==================================================
	# SHOW WARNING
	# ==================================================

	if hud != null:
		hud.show_security_warning(detection_timer)


	print("==============================")
	print("SECURITY VEHICLE DETECTED PLAYER!")
	print("MOVE AWAY!")
	print("TIME: ", detection_timer)
	print("==============================")


# ==================================================
# PLAYER LEAVES DETECTION ZONE
# ==================================================

func _on_body_exited(body: Node3D) -> void:

	if not body.is_in_group("player_vehicle"):
		return


	player_detected = false
	detection_timer = 0.0


	# ==================================================
	# 🔊 STOP SECURITY DETECTION SOUND
	# ==================================================

	AudioManager.stop_security_detect()


	# ==================================================
	# RESUME SECURITY VEHICLE
	# ==================================================

	if security_vehicle.has_method("resume_vehicle"):
		security_vehicle.resume_vehicle()


	# ==================================================
	# HIDE WARNING
	# ==================================================

	if hud != null:
		hud.hide_security_warning()


	print("==============================")
	print("PLAYER ESCAPED SECURITY ZONE")
	print("DETECTION CLEARED")
	print("==============================")


# ==================================================
# COUNTDOWN
# ==================================================

func _process(delta):

	if not player_detected:
		return


	# ==================================================
	# DECREASE DETECTION TIMER
	# ==================================================

	detection_timer -= delta


	if detection_timer < 0.0:
		detection_timer = 0.0


	# ==================================================
	# UPDATE HUD
	# ==================================================

	if hud != null:
		hud.update_security_warning(detection_timer)


	print(
		"SECURITY COUNTDOWN: ",
		snapped(detection_timer, 0.1)
	)


	# ==================================================
	# PLAYER STAYED TOO LONG
	# ==================================================

	if detection_timer <= 0.0:

		player_detected = false


		# ==================================================
		# 🔊 STOP SECURITY DETECTION SOUND
		# ==================================================

		AudioManager.stop_security_detect()


		print("==============================")
		print("PLAYER CAUGHT!")
		print("MISSION FAILED!")
		print("==============================")


		# ==================================================
		# HIDE WARNING
		# ==================================================

		if hud != null:
			hud.hide_security_warning()


		# ==================================================
		# STOP SECURITY VEHICLE
		# ==================================================

		if security_vehicle.has_method("pause_vehicle"):
			security_vehicle.pause_vehicle()


		# ==================================================
		# FAIL MISSION
		# ==================================================

		fail_mission()


# ==================================================
# FAIL MISSION
# ==================================================

func fail_mission():

	var level_manager = get_tree().get_first_node_in_group(
		"level_manager"
	)


	if level_manager != null:

		level_manager.fail_level(
			"CAUGHT BY SECURITY VEHICLE"
		)

	else:

		print("WARNING: LevelManager not found!")
