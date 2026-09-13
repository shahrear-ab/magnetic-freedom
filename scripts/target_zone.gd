extends Area3D

var delivered_count: int = 0


func _on_body_entered(body: Node3D) -> void:

	print("OBJECT ENTERED TARGET: ", body.name)

	# Only accept pickup objects
	if body.name.begins_with("PickupObject"):

		delivered_count += 1

		print("================================")
		print("OBJECT DELIVERED!")
		print("TOTAL DELIVERED: ", delivered_count)
		print("================================")

		# If the object is currently being held
		# remove it from the magnet
		if body.get_parent().name == "Magnet":

			body.reparent(get_tree().current_scene, true)

			if body is RigidBody3D:
				body.freeze = false

		# Put the object inside the delivery zone
		body.global_position = global_position + Vector3(0, 0.5, 0)

		# Stop the object moving
		if body is RigidBody3D:
			body.linear_velocity = Vector3.ZERO
			body.angular_velocity = Vector3.ZERO
