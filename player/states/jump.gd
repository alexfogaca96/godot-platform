extends State
class_name Jump

## starting jump velocity
@export var jump_min_velocity := -100.0
## maximum jump velocity
@export var jump_max_velocity := -1000.0
## acceleration applied to jump velocity each frame jump is pressed after start (start and end are interpolated linearly)
@export var jump_start_acceleration := -30.0
@export var jump_end_acceleration := -400.0
## how many frames acceleration can be applied, after this holding jump will not do anythig;
## this also defines that maximum jump velocity will probably only be achieved by holding jump for 8 frames,
## and that holding jump less frames than that will do a smaller jump
@export var jump_max_acceleration_frames := 6.0
## gravity multiplier when jump is released to fall faster at that rate and control better landing
@export var jump_release_gravity_multiplier := 2.5
## general gravity multiplier for jump (useful for trying to make jump more dynamic and less floaty)
@export var gravity_multiplier := 1.5
## horizontal movement speed while jumping
@export var horizontal_speed := 600.0

@export_group("Components")
@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var text_debug: Label

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var jump_frames := 0
var jump_acceleration_frame_percentage := 1.0 / jump_max_acceleration_frames
var released_jump := false


func _enter(_args: Dictionary = {}) -> void:
	animated_sprite.play("jump")
	player.velocity.y = jump_min_velocity
	jump_frames = 0
	released_jump = false
	text_debug.text = "jump"


func _exit() -> Dictionary:
	animated_sprite.stop()
	return {}

func _physics_update(delta: float) -> void:
	if not released_jump:
		released_jump = not Input.is_action_pressed("jump")
	if not released_jump and player.velocity.y > jump_max_velocity and jump_frames < jump_max_acceleration_frames:
		jump_frames += 1
		text_debug.text = str("jump frame ", jump_frames)
		var acceleration = lerp(jump_start_acceleration, jump_end_acceleration, jump_frames * jump_acceleration_frame_percentage)
		player.velocity.y = clamp(player.velocity.y + acceleration, jump_max_velocity, 0)
		if player.velocity.y == jump_max_velocity:
			text_debug.text = "jump max"
			jump_frames = jump_max_acceleration_frames
	
	if released_jump:
		text_debug.text = "jump released"
		player.velocity.y += gravity * delta * jump_release_gravity_multiplier
	else:
		player.velocity.y += gravity * delta * gravity_multiplier
	
	if player.velocity.y > 0:
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

