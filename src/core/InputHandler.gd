extends Node

## Input Handler.
## Abstracts input from keyboard, mouse, gamepad, and touch.

func _ready():
	print("[InputHandler] Initialized.")

func get_input_action(action: String) -> bool:
	return Input.is_action_pressed(action)

func get_mouse_position() -> Vector2:
	return get_viewport().get_mouse_position()
