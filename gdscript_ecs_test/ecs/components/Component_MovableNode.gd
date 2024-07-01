class_name Component_MovableNode extends EcsComponentBase
const NAME = &"MovableNode"

## Node instances in the Godot scene tree
## Nodes must have the following methods:
##  - 'System_Movement.gd' used method: movement_set_data(position: Vector2, direction: Vector2i)
var node: Node = null

func get_property_name_list_of_hidden() -> PackedStringArray:
	# Hide some properties to prevent them from being serialized.
	return ["node"]
