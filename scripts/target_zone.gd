extends Area3D


# ==================================================
# DELIVERY SETTINGS
# ==================================================

var delivered_count: int = 0

# Keep track of objects already delivered
var delivered_objects: Array[Node3D] = []


# ==================================================
# READY
# ==================================================

func _ready():

	print("DELIVERY ZONE READY")

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


# ==================================================
# RESET DELIVERY ZONE
# ==================================================

func reset_delivery_zone():

	# Reset delivery counter
	delivered_count = 0

	# Forget all previously delivered boxes
	delivered_objects.clear()

	print("DELIVERY ZONE RESET")


# ==================================================
# OBJECT ENTERS DELIVERY ZONE
# ==================================================

func _on_body_entered(body: Node3D) -> void:

	# Only accept pickupable objects
	if not body.is_in_group("pickupable"):
		return

	# Don't count the same box twice
	if body in delivered_objects:
		return

	print("OBJECT ENTERED DELIVERY ZONE: ", body.name)

	# Remember this object
	delivered_objects.append(body)
	body.remove_from_group("pickupable")

	if body is RigidBody3D:

		var rigid_body := body as RigidBody3D

		rigid_body.freeze = true
		rigid_body.linear_velocity = Vector3.ZERO
		rigid_body.angular_velocity = Vector3.ZERO

		var collision_shape = body.get_node_or_null(
			"CollisionShape3D"
		) as CollisionShape3D

		if collision_shape != null:

			collision_shape.disabled = true

	# Increase delivery count
	delivered_count += 1

	print("DELIVERED COUNT: ", delivered_count)


	# ==================================================
	# TELL LEVEL MANAGER
	# ==================================================

	var level_manager = get_tree().get_first_node_in_group("level_manager")

	if level_manager != null:

		level_manager.box_delivered()

	else:

		print("WARNING: LevelManager not found!")


	# ==================================================
	# STOP BOX PHYSICS
	# ==================================================

	if body is RigidBody3D:

		body.freeze = true
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
