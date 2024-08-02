extends State
class_name Walk

@export var speed := 600.0
## how many pixels player will be moved up when facing a small collision at their feet and no collision on their torso/head
@export var minimal_collision_bump := -10.0

@export_group("Components")
@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var left_torso_area: Area2D
@export var right_torso_area: Area2D
@export var left_foot_area: Area2D
@export var right_foot_area: Area2D
@export var left_bottom_area: Area2D
@export var right_bottom_area: Area2D


func _enter(_args: Dictionary = {}) -> void:
	animated_sprite.play("walk")

func _exit() -> Dictionary:
	animated_sprite.stop()
	return {}

func _physics_update(_delta: float) -> void:
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
		return
	
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return
	
	var walk_direction = Input.get_axis("move_left", "move_right")
	if walk_direction:
		player.velocity.x = walk_direction * speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		if player.velocity.x == 0:
			transitioned.emit(self, "idle")
			return
	
	if player.velocity.x < 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
	
	var safe_walk = Input.is_action_pressed("safe_walk")
	if safe_walk:
		var area = left_bottom_area if player.velocity.x < 0 else right_bottom_area
		if not area.has_overlapping_bodies():
			player.velocity.x = 0
	
	if player.velocity.x < 0 and left_foot_area.has_overlapping_bodies() and not left_torso_area.has_overlapping_bodies():
		player.position.y -= minimal_collision_bump
	elif player.velocity.x > 0 and right_foot_area.has_overlapping_bodies() and not right_torso_area.has_overlapping_bodies():
		player.position.y -= minimal_collision_bump
	
	player.move_and_slide()
