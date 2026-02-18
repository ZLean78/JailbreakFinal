extends Panel

signal back_pressed

@onready var master_slider: HSlider = $VBoxContainer/MasterSlider
@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXSlider
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready():
	# Connect signals
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_pressed)
	visibility_changed.connect(_on_visibility_changed)

	# Process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Initialize sliders with current values
	_sync_sliders()

func _on_visibility_changed():
	if visible:
		_sync_sliders()

func _sync_sliders():
	# Update sliders to match current VolumeManager values
	master_slider.set_value_no_signal(VolumeManager.master_volume)
	music_slider.set_value_no_signal(VolumeManager.music_volume)
	sfx_slider.set_value_no_signal(VolumeManager.sfx_volume)

func _on_master_changed(value: float):
	VolumeManager.set_master_volume(value)

func _on_music_changed(value: float):
	VolumeManager.set_music_volume(value)

func _on_sfx_changed(value: float):
	VolumeManager.set_sfx_volume(value)

func _on_back_pressed():
	VolumeManager.save_settings()
	back_pressed.emit()
