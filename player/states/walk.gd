extends State
class_name Walk

@export var speed := 600.0

@export_group("Components")
@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var text_debug: Label


func _enter(_args: Dictionary = {}) -> void:
	animated_sprite.play("walk")
	text_debug.text = "walk"

func _exit() -> Dictionary:
	animated_sprite.stop()
	return {}

func _physics_update(_delta: float) -> void:
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
	elif player.velocity.x > 0:
		animated_sprite.flip_h = false
	
	player.move_and_slide()
	
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
		return
