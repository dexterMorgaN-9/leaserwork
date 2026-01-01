extends Node2D

@export var obstacle_scene: PackedScene

@onready var guy = $Player
@onready var start = $SpawnPoint
@onready var finish = $GoalZone
@onready var deaths_text = $UI/Control/FailLabel
@onready var stage_text = $UI/Control/LevelLabel
@onready var enemies = $Obstacles
@onready var exit = $UI/Control/BackButton

var deaths: int = 0

func spawn_ring(center: Vector2, speed: float, radius: float):
	var thing = obstacle_scene.instantiate()
	thing.position = center
	enemies.add_child(thing)
	thing.pattern = 3
	thing.speed = speed
	thing.move_range = radius

func leave():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func build():
	var spots = [
		Vector2(400, 200), Vector2(560, 200), Vector2(720, 200), Vector2(880, 200),
		Vector2(400, 360), Vector2(560, 360), Vector2(720, 360), Vector2(880, 360),
		Vector2(400, 520), Vector2(560, 520), Vector2(720, 520), Vector2(880, 520)
	]
	
	for spot in spots:
		spawn_ring(spot, 150, 45)

func refresh():
	deaths_text.text = "FAILS: " + str(deaths)

func _ready():
	if !obstacle_scene:
		obstacle_scene = load("res://scenes/obstacle.tscn")
	
	guy.position = start.position
	guy.player_died.connect(ouch)
	exit.pressed.connect(leave)
	
	stage_text.text = "LEVEL: HARD"
	refresh()
	build()
	
	await get_tree().create_timer(0.5).timeout
	finish.body_entered.connect(win)

func ouch():
	deaths += 1
	refresh()
	guy.position = start.position

func win(body):
	if body == guy:
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
