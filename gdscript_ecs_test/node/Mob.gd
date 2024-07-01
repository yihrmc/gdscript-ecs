extends RigidBody2D

var _ref_world: WeakRef = null
var _world: EcsWorld:
	get:
		if _ref_world == null:
			return null
		return _ref_world.get_ref()
	set(world):
		_ref_world = weakref(world)

## The caller is: System_Movement.gd::_on_update()
func movement_set_data(data_position: Vector2, _direction: Vector2i) -> void:
	# Set the node's own position
	position = data_position
