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
## how many frames to consider a jump input buffer, so you don't have to be super precise with landing and hitting jump
@export var jump_buffer_frames := 10
## this enables coyote time, so players are able to jump right at the beginning of falling
@export var initial_frames_to_jump := 12
## how many pixels player will be moved up when facing a small collision at their feet and no collision on their torso/head
@export var minimal_collision_bump := 15.0

@export_group("Components")
@export var player: CharacterBody2D
@export var left_torso_area: Area2D
@export var right_torso_area: Area2D
@export var left_foot_area: Area2D
@export var right_foot_area: Area2D

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var fall_acceleration_per_frame := (fall_velocity_multiplier - 1.0) / fall_acceleration_frames
var current_fall_acceleration_frames: int
var current_gliding_frames: int
var jump_if_grounded_in_frames: int
var current_frame: int


func _enter(_args: Dictionary = {}) -> void:
	current_fall_acceleration_frames = 0
	current_gliding_frames = 0
	jump_if_grounded_in_frames = 0
	current_frame = initial_frames_to_jump if _args.has("jump") else 0

func _exit() -> Dictionary:
	if current_frame <= initial_frames_to_jump:
		return { "coyote_time": true }
	if jump_if_grounded_in_frames > 0:
		return { "jump_buffer": true }
	return {}

func _physics_update(delta: float) -> void:
	current_frame += 1
	
	if Input.is_action_just_pressed("jump"):
		if current_frame <= initial_frames_to_jump:
			transitioned.emit(self, "jump")
			return
		jump_if_grounded_in_frames = jump_buffer_frames
	elif jump_if_grounded_in_frames > 0:
		jump_if_grounded_in_frames -= 1
	
	if player.is_on_floor():
		if jump_if_grounded_in_frames > 0:
			transitioned.emit(self, "jump")
		elif Input.get_axis("move_left", "move_right") != 0:
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
	
	if player.velocity.x < 0 and left_foot_area.has_overlapping_bodies() and not left_torso_area.has_overlapping_bodies():
		player.position.y -= minimal_collision_bump
	elif player.velocity.x > 0 and right_foot_area.has_overlapping_bodies() and not right_torso_area.has_overlapping_bodies():
		player.position.y -= minimal_collision_bump
	
	player.move_and_slide()
