extends EcsSystemBase

func _on_pre_update(uplink_data: Dictionary) -> Dictionary:
	var mob_entity_list = world.find_entity_list(Component_Mob.NAME)
	for mob_entity in mob_entity_list:
		var component_position = mob_entity.get_component(Component_Position.NAME) as Component_Position
		if component_position.direction == Vector2i.ZERO:
			component_position.direction = _random_direction()
		elif command("is_component_position_hits_wall").call(
				component_position,
				uplink_data.screen_size) != Vector2i.ZERO:
			component_position.direction = _random_direction()
		pass
	return uplink_data

func _random_direction() -> Vector2i:
	return Vector2i(randi_range(-1, 1), randi_range(-1, 1))
