extends CharacterBody2D

signal player_died

const pace = 200.0

@onready var body = $Sprite2D
@onready var box = $CollisionShape2D
@onready var burst = $DeathParticles
@onready var scream = $DeathSound

var dead = false

func respawn():
	dead = false
	body.visible = true
	box.disabled = false
	burst.emitting = false

func _ready():
	add_to_group("player")
	burst.emitting = false

func hit():
	if dead:
		return
	
	dead = true
	player_died.emit()
	
	if scream:
		scream.play()
	
	burst.emitting = true
	body.visible = false
	box.set_deferred("disabled", true)
	
	var cam = get_viewport().get_camera_2d()
	if cam and cam.has_method("apply_shake"):
		cam.apply_shake(0.3, 15)
	
	await get_tree().create_timer(0.5).timeout
	respawn()

func _physics_process(_delta):
	if dead:
		return
	
	var move = Vector2.ZERO
	move.x = Input.get_axis("ui_left", "ui_right")
	move.y = Input.get_axis("ui_up", "ui_down")
	
	if move.length() > 0:
		move = move.normalized()
	
	velocity = move * pace
	
	move_and_slide()

func _on_area_2d_area_entered(area):
	if area.is_in_group("obstacles"):
		hit()
