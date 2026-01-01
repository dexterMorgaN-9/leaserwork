extends Control

@onready var btn1 = $VBoxContainer/EasyButton
@onready var btn2 = $VBoxContainer/MediumButton
@onready var btn3 = $VBoxContainer/HardButton
@onready var back = $Backbutton
@onready var back_txt = $Backbutton/Label
@onready var sound_btn = $MuteButton
@onready var sound_txt = $MuteButton/Label
@onready var beep = $ButtonClickSound

var muted = false

func swap_sound():
	if sound_txt:
		if muted:
			sound_txt.text = "🔇"
		else:
			sound_txt.text = "🔊"

func toggle():
	muted = !muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
	swap_sound()

func goto_easy():
	if beep:
		beep.play()
		await beep.finished
	get_tree().change_scene_to_file("res://scenes/level_easy.tscn")

func goto_mid():
	if beep:
		beep.play()
		await beep.finished
	get_tree().change_scene_to_file("res://scenes/level_medium.tscn")

func _ready():
	if back_txt:
		back_txt.text = "← BACK"
	
	swap_sound()
	
	btn1.pressed.connect(goto_easy)
	btn2.pressed.connect(goto_mid)
	btn3.pressed.connect(goto_hard)
	back.pressed.connect(exit)
	
	if sound_btn:
		sound_btn.pressed.connect(toggle)

func goto_hard():
	if beep:
		beep.play()
		await beep.finished
	get_tree().change_scene_to_file("res://scenes/level_hard.tscn")

func exit():
	if beep:
		beep.play()
		await beep.finished
	get_tree().change_scene_to_file("res://main_selection.tscn")
