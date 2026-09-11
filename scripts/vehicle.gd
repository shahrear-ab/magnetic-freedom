extends CharacterBody3D

@export var move_speed := 8.0
@export var turn_speed := 2.5

func _physics_process(delta):
	var forward_input = Input.get_axis("move_backward", "move_forward")
	var turn_input = Input.get_axis("turn_left", "turn_right")

	if forward_input != 0:
		print("FORWARD INPUT: ", forward_input)

	if turn_input != 0:
		print("TURN INPUT: ", turn_input)

	var forward_direction = -transform.basis.z

	velocity = forward_direction * forward_input * move_speed

	rotate_y(-turn_input * turn_speed * delta)

	move_and_slide()
