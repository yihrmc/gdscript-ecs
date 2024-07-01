extends EcsSystemBase

func _on_before_ready() -> void:
	add_system_command("create_mob_entity", create_mob_entity)
	pass

func create_mob_entity() -> EcsEntity:
	var mob_entity = world.create_entity()

	mob_entity.create_component(Component_Mob.NAME)

	var component_position = mob_entity.create_component(Component_Position.NAME) as Component_Position
	component_position.position = Vector2(50, 50)

	var component_movablenode = mob_entity.create_component(Component_MovableNode.NAME) as Component_MovableNode
	component_movablenode.node = command("create_mob_node").call()

	return mob_entity
