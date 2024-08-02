extends State
class_name Idle

@export_group("Components")
@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D


func _enter(_args: Dictionary = {}) -> void:
	animated_sprite.play("idle")

func _exit() -> Dictionary:
	animated_sprite.stop()
	return {}

func _physics_process(_delta) -> void:
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return
	if Input.get_axis("move_left", "move_right") != 0:
		transitioned.emit(self, "walk")
		return 
