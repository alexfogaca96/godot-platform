extends State
class_name Idle

@export_group("Components")
@export var player: CharacterBody2D


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return
	if Input.get_axis("move_left", "move_right") != 0:
		transitioned.emit(self, "walk")
		return 
