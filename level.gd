extends Node2D

@onready var start = $"Start button"
@onready var back = $"Back button"
@onready var back_text = $"Back button/Label"
@onready var info = $UI/Label
@onready var grid = $UI/MarginContainer/VBoxContainer/GridContainer
@onready var clock = $UI/MarginContainer/"Show Timer"
@onready var bg = $Background

@onready var click = $ClickSound
@onready var good = $CorrectSound
@onready var bad = $WrongSound
@onready var victory = $WinSound

var cards = []
var nums = []
var faces = []
var cover

var target = 1
var active = false
var peek = true
var hue = 0.0

func shake(card):
	var spot = card.position
	var anim = create_tween()
	anim.set_loops(3)
	anim.tween_property(card, "position:x", spot.x + 6, 0.05)
	anim.tween_property(card, "position:x", spot.x - 6, 0.05)
	anim.chain().tween_property(card, "position", spot, 0.07)

func party():
	for i in range(25):
		await get_tree().create_timer(0.03 * i).timeout
		
		var c = cards[i]
		var anim = create_tween()
		anim.set_parallel(true)
		anim.tween_property(c, "scale", Vector2(1.15, 1.15), 0.4)
		anim.tween_property(c, "rotation", deg_to_rad(360), 0.4)
		
		anim.chain().tween_property(c, "scale", Vector2.ONE, 0.25)
		anim.tween_property(c, "rotation", 0, 0.25)
		
		var color = float(i) / 25.0
		c.modulate = Color.from_hsv(color, 0.7, 1.0)

func flip(card, img):
	var anim = create_tween()
	anim.set_parallel(true)
	anim.tween_property(card, "scale:x", 0.0, 0.12)
	
	anim.chain().tween_callback(func(): card.texture_normal = img)
	
	anim.chain().set_parallel(true)
	anim.tween_property(card, "scale:x", 1.0, 0.12)

func win():
	if victory:
		victory.play()
	
	info.text = "You Won!"
	active = false
	start.disabled = false
	start.text = "Play Again"
	
	for i in range(25):
		cards[i].texture_normal = faces[nums[i] - 1]
	
	party()

func press(i):
	if not active or peek or cards[i].disabled:
		return
	
	if click:
		click.play()
	
	var val = nums[i]
	var show = faces[val - 1]
	
	flip(cards[i], show)
	await get_tree().create_timer(0.25).timeout
	
	if val == target:
		if good:
			good.play()
		
		pop(cards[i])
		cards[i].disabled = true
		target += 1
		
		if target > 25:
			win()
		else:
			info.text = "Correct! Find: " + str(target)
	else:
		if bad:
			bad.play()
		
		shake(cards[i])
		info.text = "Wrong! Restarting..."
		await get_tree().create_timer(1).timeout
		setup()

func _process(delta):
	if bg:
		hue += delta * 0.04
		if hue > 1:
			hue = 0
		bg.color = Color.from_hsv(hue, 0.25, 0.18)

func begin():
	if click:
		click.play()
	
	start.disabled = true
	start.text = "Playing..."
	
	var mix = range(25)
	mix.shuffle()
	
	for i in range(25):
		nums[i] = mix[i] + 1
		cards[i].texture_normal = faces[mix[i]]
	
	info.text = "Memorize the cards!"
	clock.start()
	active = true
	peek = true

func pop(card):
	var anim = create_tween()
	anim.tween_property(card, "scale", Vector2(1.25, 1.25), 0.25)
	anim.tween_property(card, "scale", Vector2.ONE, 0.25)

func _ready():
	start.pressed.connect(begin)
	back.pressed.connect(leave)
	
	if back_text:
		back_text.text = "← BACK"
	
	clock.timeout.connect(cover_cards)
	
	for i in range(25):
		var btn = grid.get_node("TextureButton" + str(i + 1))
		if btn:
			cards.append(btn)
			faces.append(btn.texture_normal)
			btn.pressed.connect(press.bind(i))
	
	cover = load("res://back.png")
	setup()

func cover_cards():
	peek = false
	
	for i in range(25):
		flip(cards[i], cover)
	
	info.text = "Find: " + str(target)

func leave():
	if click:
		click.play()
		await click.finished
	get_tree().change_scene_to_file("res://main_selection.tscn")

func setup():
	active = false
	peek = true
	target = 1
	
	nums.clear()
	for i in range(25):
		nums.append(i + 1)
		cards[i].texture_normal = faces[i]
		cards[i].disabled = false
		cards[i].scale = Vector2.ONE
		cards[i].rotation = 0
		cards[i].modulate = Color.WHITE
	
	start.disabled = false
	start.text = "Start"
