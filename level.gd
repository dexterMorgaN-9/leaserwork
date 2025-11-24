extends Node2D

@onready var start_btn = $"UI/MarginContainer/VBoxContainer/TopPanel/Start button"
@onready var status = $UI/MarginContainer/VBoxContainer/TopPanel/StatusLabel
@onready var grid = $UI/MarginContainer/VBoxContainer/GridContainer
@onready var timer = $"Show Timer"

var buttons = []
var numbers = []
var next_num = 1
var playing = false
var showing = true

func _ready():
	start_btn.pressed.connect(start_game)
	timer.timeout.connect(hide_numbers)
	
	for i in range(25):
		var btn = grid.get_node("TextureButton" + str(i + 1))
		if btn:
			buttons.append(btn)
			btn.pressed.connect(clicked.bind(i))
			
			var lbl = Label.new()
			lbl.name = "NumberLabel"
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			lbl.add_theme_font_size_override("font_size", 24)
			btn.add_child(lbl)
	
	reset()

func reset():
	playing = false
	showing = true
	next_num = 1
	
	numbers.clear()
	for i in range(25):
		numbers.append(i + 1)
	
	for i in range(25):
		show_tile(i, numbers[i], true)
	
	for btn in buttons:
		btn.disabled = false
	
	status.text = "Click Start to begin!"
	start_btn.disabled = false
	start_btn.text = "Start Game"

func start_game():
	start_btn.disabled = true
	start_btn.text = "Playing..."
	
	numbers.shuffle()
	
	for i in range(25):
		show_tile(i, numbers[i], true)
	
	status.text = "Memorize! (" + str(int(timer.wait_time)) + " sec)"
	
	timer.start()
	playing = true
	showing = true

func hide_numbers():
	showing = false
	
	for i in range(25):
		show_tile(i, numbers[i], false)
	
	status.text = "Find: " + str(next_num)

func clicked(idx):
	if not playing:
		return
	
	if showing:
		return
	
	var val = numbers[idx]
	
	if val == next_num:
		show_tile(idx, val, true)
		buttons[idx].disabled = true
		next_num += 1
		
		if next_num > 25:
			you_win()
		else:
			status.text = "Find: " + str(next_num)
	else:
		status.text = "Wrong! Restarting..."
		await get_tree().create_timer(1.0).timeout
		reset()

func you_win():
	playing = false
	status.text = "🎉 You Won! 🎉"
	start_btn.disabled = false
	start_btn.text = "Play Again"
	
	for i in range(25):
		show_tile(i, numbers[i], true)

func show_tile(idx, num, visible):
	var btn = buttons[idx]
	var lbl = btn.get_node("NumberLabel")
	
	if visible:
		lbl.text = str(num)
	else:
		lbl.text = "?"
	lbl.visible = true
