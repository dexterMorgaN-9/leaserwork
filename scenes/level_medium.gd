extends Node2D

@export var obstacle_scene: PackedScene
@onready var hero = $Player
@onready var origin = $SpawnPoint
@onready var target = $GoalZone
@onready var counter = $UI/Control/FailLabel
@onready var title = $UI/Control/LevelLabel
@onready var hazards = $Obstacle
@onready var menu = $UI/Control/BackButton

var tries: int = 0

func tally():
	counter.text = "FAILS: " + str(tries)

func respawn():
	tries += 1
	tally()
	hero.position = origin.position

func place(spot: Vector2, rate: float, radius: float, phase: float):
	var thing = obstacle_scene.instantiate()
	hazards.add_child(thing)
	thing.position = spot
	thing.pattern = 1
	thing.speed = rate
	thing.move_range = radius
	thing.move_timer = phase

func arrange():
	var spots = [
		Vector2(350, 324),
		Vector2(480, 324),
		Vector2(576, 324),
		Vector2(672, 324),
		Vector2(768, 324),
		Vector2(864, 324)
	]
	
	for point in spots:
		var shift = randf() * TAU
		place(point, 80, 60, shift)

func reached(body):
	if body == hero:
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func exit():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func initialize():
	if !obstacle_scene:
		obstacle_scene = load("res://scenes/obstacle.tscn")
	
	hero.position = origin.position
	hero.player_died.connect(respawn)
	menu.pressed.connect(exit)
	title.text = "LEVEL: MEDIUM"
	tally()
	
	for node in hazards.get_children():
		node.queue_free()
	
	if hero.has_node("Area2D"):
		hero.get_node("Area2D").monitoring = false
	
	await get_tree().create_timer(0.5).timeout
	arrange()
	await get_tree().create_timer(0.5).timeout
	
	if hero.has_node("Area2D"):
		hero.get_node("Area2D").monitoring = true
	
	target.body_entered.connect(reached)

func _ready():
	initialize()
