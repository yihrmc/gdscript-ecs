extends Area2D

@onready var icon: Sprite2D = $Icon

## Size of the game window.
var _screen_size

var _ref_world: WeakRef = null
var _world: EcsWorld:
	get:
		if _ref_world == null:
			return null
		return _ref_world.get_ref()
	set(world):
		_ref_world = weakref(world)

## The caller is: System_Movement.gd::_on_update()
func movement_set_data(data_position: Vector2, direction: Vector2i) -> void:
	# Set the node's own position
	position = data_position
	# Using shaders to change the direction of the image
	var shader := icon.material as ShaderMaterial
	shader.set_shader_parameter("pitch", direction.x * 0.3)
	shader.set_shader_parameter("roll", -direction.y * 0.3)
	pass

func get_player_direction() -> Vector2i:
	var direction = Vector2i.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	return direction
