extends Node
class_name State

@warning_ignore("unused_signal")
signal transitioned


func _enter(_args: Dictionary = {}) -> void:
	pass

func _exit() -> Dictionary:
	return {}

func _update(_delta: float) -> void:
	pass

func _physics_update(_delta: float) -> void:
	pass
