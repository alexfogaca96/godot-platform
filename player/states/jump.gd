extends State
class_name Jump

## jump velocity applied at beggining of jump
@export var jump_velocity := -1100.0
## how many frames it will take to slow down jump velocity after releasing jump
@export var jump_release_slowdown_velocity_frames := 10
## when jump reaches this min velocity it releases the jump forcefully so you don't have to hold jump forever to jump longer
@export var jump_force_release_max_velocity := -600.0
## general gravity multiplier for jump (useful for trying to make jump more dynamic and less floaty)
@export var gravity_multiplier := 1.8
## horizontal movement speed while jumping
@export var horizontal_speed := 630.0

@export_group("Components")
@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var text_debug: Label

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var released_jump: bool
var jump_released_frames: int
var initial_released_jump_velocity: float


func _enter(_args: Dictionary = {}) -> void:
	player.velocity.y = jump_velocity
	released_jump = false
	jump_released_frames = 0
	animated_sprite.play("jump")
	text_debug.text = "jump"


func _exit() -> Dictionary:
	animated_sprite.stop()
	return {}

func _physics_update(delta: float) -> void:
	if not released_jump:
		released_jump = not Input.is_action_pressed("jump")
		if player.velocity.y > jump_force_release_max_velocity:
			released_jump = true
	
	if not released_jump:
		player.velocity.y += gravity * delta * gravity_multiplier
	else:
		if jump_released_frames == 0:
			initial_released_jump_velocity = player.velocity.y
		jump_released_frames += 1
		player.velocity.y = lerp(initial_released_jump_velocity, 0.0, float(jump_released_frames) / float(jump_release_slowdown_velocity_frames))
	
	if player.velocity.y >= 0:
		transitioned.emit(self, "fall")
		return
	
	var walk_direction = Input.get_axis("move_left", "move_right")
	if walk_direction:
		player.velocity.x = walk_direction * horizontal_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, horizontal_speed)
	
	if player.velocity.x < 0:
		animated_sprite.flip_h = true
	elif player.velocity.x > 0:
		animated_sprite.flip_h = false
	
	player.move_and_slide()

