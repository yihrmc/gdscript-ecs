##
## Provide mobility for all entities
##
extends EcsSystemBase

func _on_ready() -> void:
	add_system_command("is_component_position_hits_wall", is_component_position_hits_wall)
	pass

func is_component_position_hits_wall(component_position: Component_Position, screen_size) -> Vector2i:
	var wall: Vector2i = Vector2i.ZERO
	if component_position.position.x == 0:
		wall.x = -1
	elif component_position.position.x == screen_size.x:
		wall.x = 1
	if component_position.position.y == 0:
		wall.y = -1
	elif component_position.position.y == screen_size.y:
		wall.y = 1
	return wall

func _on_update(downlink_data: Dictionary) -> Dictionary:
	var process_delta = downlink_data.process_delta as float
	if process_delta == null:
		return downlink_data
	var entity_list = world.find_entity_list(Component_Position.NAME)
	for entity in entity_list:
		# Update Position
		var position = entity.get_component(Component_Position.NAME) as Component_Position
		assert(position != null)
		var velocity = Vector2(position.direction)
		if velocity.length() > 0:
			velocity = velocity.normalized() * position.speed
		position.position += velocity * process_delta
		position.position = position.position.clamp(Vector2.ZERO, downlink_data.screen_size)
		# Assign the calculated data to the Godot node
		var movable_node = entity.get_component(Component_MovableNode.NAME) as Component_MovableNode
		if movable_node != null:
			movable_node.node.movement_set_data(position.position, position.direction)
			pass
		pass
	return downlink_data
