extends Area2D

enum MovePattern { HORIZONTAL, VERTICAL, SQUARE, CIRCULAR }

@export var pattern: int = 0
@export var speed: float = 100.0
@export var move_range: float = 150.0

var home: Vector2
var time: float = 0.0
var angle: float = 0.0

const buffer = 15.0

const safe_x1 = -44
const safe_x2 = 156
const safe_y1 = 249
const safe_y2 = 375

const goal_x1 = 964
const goal_x2 = 1148
const goal_y1 = 217
const goal_y2 = 343

func blocked(pos: Vector2) -> bool:
	if pos.x >= safe_x1 and pos.x <= safe_x2 and pos.y >= safe_y1 and pos.y <= safe_y2:
		return true
	
	if pos.x >= goal_x1 and pos.x <= goal_x2 and pos.y >= goal_y1 and pos.y <= goal_y2:
		return true
	
	return false

func _ready():
	home = position
	add_to_group("obstacles")
	angle = randf() * TAU
	body_entered.connect(touch)

func touch(body):
	if body.is_in_group("player") or body.name == "Player":
		if body.has_method("die"):
			body.die()

func _process(delta):
	time += delta
	
	var next = position
	
	match pattern:
		0:
			next.x = home.x + sin(time * speed / 100.0) * move_range
			next.y = home.y
		
		1:
			next.x = home.x
			next.y = home.y + sin(time * speed / 100.0) * move_range
		
		2:
			var step = move_range / speed
			var loop = step * 4
			var now = fmod(time, loop)
			
			if now < step:
				next.x = home.x + (now / step) * move_range
				next.y = home.y
			elif now < step * 2:
				next.x = home.x + move_range
				next.y = home.y + ((now - step) / step) * move_range
			elif now < step * 3:
				next.x = home.x + move_range - ((now - step * 2) / step) * move_range
				next.y = home.y + move_range
			else:
				next.x = home.x
				next.y = home.y + move_range - ((now - step * 3) / step) * move_range
		
		3:
			angle += (speed / 100.0) * delta
			next.x = home.x + cos(angle) * move_range
			next.y = home.y + sin(angle) * move_range
	
	if not blocked(next):
		position = next
