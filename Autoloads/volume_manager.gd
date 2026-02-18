extends Node

const SETTINGS_PATH := "user://settings.cfg"
const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready():
	_create_audio_buses()
	load_settings()
	_apply_volumes()

func _create_audio_buses():
	# Check if buses already exist (in case of scene reload)
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus()
		var music_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_idx, BUS_MUSIC)
		AudioServer.set_bus_send(music_idx, BUS_MASTER)

	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		var sfx_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_idx, BUS_SFX)
		AudioServer.set_bus_send(sfx_idx, BUS_MASTER)

func _apply_volumes():
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(BUS_MASTER)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(master_volume))

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(BUS_MUSIC)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(BUS_SFX)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	var err = config.save(SETTINGS_PATH)
	if err != OK:
		print("VolumeManager: Failed to save settings, error: ", err)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		master_volume = config.get_value("audio", "master", 1.0)
		music_volume = config.get_value("audio", "music", 1.0)
		sfx_volume = config.get_value("audio", "sfx", 1.0)
	# If file doesn't exist, use default values (1.0)
