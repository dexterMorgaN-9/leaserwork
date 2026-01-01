extends Control

@onready var mem = $MemoryButton
@onready var hard = $WorldHardestButton
@onready var title = $TitleLabel
@onready var click = $ButtonClickSound
@onready var tune = $MenuMusic

func pick_hard():
	click.play()
	await click.finished
	
	if tune:
		tune.stop()
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _ready():
	title.text = "CHOOSE YOUR GAME"
	
	mem.pressed.connect(pick_mem)
	hard.pressed.connect(pick_hard)
	
	if tune:
		tune.play()

func pick_mem():
	click.play()
	await click.finished
	
	if tune:
		tune.stop()
	
	get_tree().change_scene_to_file("res://level.tscn")
