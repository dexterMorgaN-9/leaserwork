extends Camera2D

var power: float = 0.0
var left: float = 0.0
var base: Vector2 = Vector2.ZERO

func apply_shake(duration: float, amount: float):
	left = duration
	power = amount

func _ready():
	base = offset

func _process(delta):
	if left > 0:
		left -= delta
		offset = base + Vector2(
			randf_range(-power, power),
			randf_range(-power, power)
		)
	else:
		offset = base
