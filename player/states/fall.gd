extends State
class_name Fall

## maximum falling velocity so gravity doesn't make the fall that much faster (bad experience)
@export var fall_max_velocity := 1100.0
## falling velocity multiplier because falling faster makes jump more sharp
@export var fall_velocity_multiplier := 3
## how many frames the fall acceleration will be applied
@export var fall_acceleration_frames := 10
## how many frames the gliding at the start of the fall takes
@export var gliding_frames := 6
## inverse multiplier for fall speed so you'll fall slowly during gliding
@export var gliding_multipler := 0.3
## horizontal movement speed while falling
@export var horizontal_speed := 660.0

@export_group("Components")
@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var text_debug: Label

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var fall_acceleration_per_frame = (fall_velocity_multiplier - 1.0) / fall_acceleration_frames
var current_fall_acceleration_frames := 0
var current_gliding_frames := 0


func _enter(_args: Dictionary = {}) -> void:
	current_fall_acceleration_frames = 0
	current_gliding_frames = 0
	animated_sprite.play("idle")
	text_debug.text = "fall"

func _exit() -> Dictionary:
	animated_sprite.stop()
	return {}

func _physics_update(delta: float) -> void:
	if player.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0:
			transitioned.emit(self, "walk")
		else:
			transitioned.emit(self, "idle")
		return
	
	if current_gliding_frames < gliding_frames:
		player.velocity.y += gravity * delta * gliding_multipler
		current_gliding_frames += 1
	else:
		var fall_velocity = (fall_velocity_multiplier + fall_acceleration_per_frame * current_fall_acceleration_frames)
		player.velocity.y += gravity * delta * fall_velocity
		player.velocity.y = clamp(player.velocity.y, 0, fall_max_velocity)
		if current_fall_acceleration_frames < fall_acceleration_frames:
			current_fall_acceleration_frames += 1
	
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
