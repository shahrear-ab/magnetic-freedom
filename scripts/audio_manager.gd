extends Node


# ==================================================
# AUDIO FILES
# ==================================================

const MUSIC_GAMEPLAY = preload("res://audio/music_gameplay.ogg")
const CAR_ENGINE = preload("res://audio/car_engine.ogg")

const UI_CLICK = preload("res://audio/ui_click.ogg")
const UI_PAUSE = preload("res://audio/ui_pause.ogg")

const MAGNET_ATTACH = preload("res://audio/magnet_attach.ogg")

const SECURITY_DETECT = preload("res://audio/security_detect.ogg")
const TIMER_WARNING = preload("res://audio/timer_warning.ogg")

const MISSION_COMPLETE = preload("res://audio/mission_complete.ogg")
const MISSION_FAILED = preload("res://audio/mission_failed.ogg")

const LEVEL_COMPLETE = preload("res://audio/level_complete.ogg")
const BOX_DELIVERED = preload("res://audio/box_delivered.ogg")


# ==================================================
# AUDIO PLAYERS
# ==================================================

var music_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Dedicated player for security detection sound
var security_player: AudioStreamPlayer


# ==================================================
# READY
# ==================================================

func _ready():

	# ==================================================
	# MAKE AUDIO CONTINUE DURING PAUSE
	# ==================================================

	process_mode = Node.PROCESS_MODE_ALWAYS


	# ==================================================
	# MUSIC
	# ==================================================

	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	music_player.stream = MUSIC_GAMEPLAY
	music_player.volume_db = -8.0


	# ==================================================
	# ENABLE MUSIC LOOPING
	# ==================================================

	if music_player.stream:

		# For AudioStreamOggVorbis and other stream types in Godot 4.7
		# use the 'loop' boolean property
		if music_player.stream.has_meta("loop") or "loop" in music_player.stream:

			music_player.stream.loop = true

			print("MUSIC LOOPING ENABLED")

		else:

			print("WARNING: Audio stream does not support loop property")


	# ==================================================
	# ENGINE
	# ==================================================

	engine_player = AudioStreamPlayer.new()
	add_child(engine_player)

	engine_player.stream = CAR_ENGINE
	engine_player.volume_db = -14.0


	# ==================================================
	# GENERAL SFX
	# ==================================================

	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

	sfx_player.volume_db = -3.0


	# ==================================================
	# SECURITY DETECTION PLAYER
	# ==================================================

	security_player = AudioStreamPlayer.new()
	add_child(security_player)

	security_player.stream = SECURITY_DETECT
	security_player.volume_db = -3.0


	# ==================================================
	# START BACKGROUND MUSIC
	# ==================================================

	play_music()


# ==================================================
# BACKGROUND MUSIC
# ==================================================

func play_music():

	if not music_player.playing:

		print("PLAYING GAMEPLAY MUSIC")

		music_player.play()


func stop_music():

	if music_player.playing:

		music_player.stop()


# ==================================================
# CAR ENGINE
# ==================================================

func start_engine():

	if not engine_player.playing:

		engine_player.play()


func stop_engine():

	if engine_player.playing:

		engine_player.stop()


# ==================================================
# GENERIC SOUND
# ==================================================

func play_sound(sound: AudioStream):

	if sound == null:

		return

	sfx_player.stream = sound
	sfx_player.play()


# ==================================================
# UI
# ==================================================

func play_click():

	play_sound(UI_CLICK)


func play_pause():

	play_sound(UI_PAUSE)


# ==================================================
# MAGNET
# ==================================================

func play_magnet():

	play_sound(MAGNET_ATTACH)


# ==================================================
# SECURITY DETECTION
# ==================================================

func play_security_detect():

	if not security_player.playing:

		print("SECURITY DETECTION SOUND START")

		security_player.play()


func stop_security_detect():

	if security_player.playing:

		print("SECURITY DETECTION SOUND STOP")

		security_player.stop()


# ==================================================
# TIMER
# ==================================================

func play_timer_warning():

	play_sound(TIMER_WARNING)


# ==================================================
# MISSION
# ==================================================

func play_box_delivered():

	play_sound(BOX_DELIVERED)


func play_mission_complete():

	play_sound(MISSION_COMPLETE)


func play_mission_failed():

	print("PLAYING MISSION FAILED SOUND")

	play_sound(MISSION_FAILED)


func play_level_complete():

	play_sound(LEVEL_COMPLETE)
