extends CanvasLayer

@onready var level_manager = $"../LevelManager"
@onready var level_label = $LevelLabel
@onready var mission_message = $MissionMessage


func _process(_delta):

	if level_manager == null:
		return

	# Normal HUD
	level_label.text = "LEVEL %d\nBOXES: %d / %d\nTIME: %d" % [
		level_manager.level_number,
		level_manager.delivered_boxes,
		level_manager.required_boxes,
		ceil(level_manager.time_left)
	]

	# Mission status
	if level_manager.mission_finished:

		if level_manager.delivered_boxes >= level_manager.required_boxes:
			mission_message.text = "MISSION COMPLETE!"
		else:
			mission_message.text = "MISSION FAILED!"

	else:
		mission_message.text = ""
