# Entity
class_name EcsEntity extends RefCounted

var _ref_world: WeakRef
var _entity_id: int

var entity_id: int:
	get: return entity_id

var world: EcsWorld:
	get: return _ref_world.get_ref()

var components: Dictionary:
	get: return world._get_components(_entity_id)

func _init(world: EcsWorld, entity_id: int) -> void:
	_ref_world = weakref(world)
	_entity_id = entity_id
	pass

func remove_self():
	world._remove_entity(_entity_id)

func create_component(component_name: StringName) -> EcsComponentBase:
	return world._create_component(_entity_id, component_name)

func has_component(component_name: StringName) -> bool:
	return components.has(component_name)

func get_component(component_name: StringName) -> EcsComponentBase:
	return components.get(component_name, null)

func remove_component(component_name: StringName) -> bool:
	return world._remove_component(_entity_id, component_name)

func remove_component_all(entity_id: int) -> void:
	world._remove_component_all(_entity_id)
