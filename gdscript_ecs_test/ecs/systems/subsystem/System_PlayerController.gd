##
## Control player movement and other behaviors
##
extends EcsSystemBase

func _on_before_ready() -> void:
	add_system_command("create_player_entity", create_player_entity)
	add_system_command("set_player_direction", set_player_direction)
	restore_nodes_from_archive()
	pass

func _on_pre_update(uplink_data: Dictionary) -> Dictionary:
	var player_entity = world.find_entity_first(Component_Player.NAME)
	if player_entity == null:
		return uplink_data
	var component_position = player_entity.get_component(Component_Position.NAME) as Component_Position
	var direction = Vector2i.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	component_position.direction = direction
	return uplink_data

func create_player_entity() -> EcsEntity:
	var player_entity = world.create_entity()

	player_entity.create_component(Component_Player.NAME)

	var component_position = player_entity.create_component(Component_Position.NAME) as Component_Position
	component_position.position = Vector2(200, 200)
	component_position.speed = 380

	var component_movablenode = player_entity.create_component(Component_MovableNode.NAME) as Component_MovableNode
	component_movablenode.node = get_command("create_player_node").call()

	return player_entity

func set_player_direction(direction: Vector2i) -> void:
	assert(direction.x >= -1 and direction.x <= 1)
	assert(direction.y >= -1 and direction.y <= 1)
	var player_entity = world.find_entity_first(Component_Player.NAME)
	if player_entity == null:
		return
	var position = player_entity.get_component(Component_Position.NAME) as Component_Position
	assert(position != null)
	position.direction = direction
	pass

func restore_nodes_from_archive() -> void:
	var player_entity = world.find_entity_first(Component_Player.NAME)
	if player_entity == null:
		return
	var movable_node = player_entity.get_component(Component_MovableNode.NAME) as Component_MovableNode
	assert(movable_node != null)
	if movable_node.node == null:
		var player_node = get_command("create_player_node").call()
		assert(player_node != null)
		movable_node.node = player_node
	pass
