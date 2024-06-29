## World
##
##  # Function Call Order
##  ## EcsWorld.new(...)
##  ↓ - EcsWorld._init()
##  ↓ for - EcsRegistrarBase._on_set_world(...)
##  ↓ for - EcsRegistrarBase._on_before_ready()
##  ↓ for - EcsRegistrarBase._on_ready()
##  ↓ EcsWorld.init_system()
##  ↓ for - EcsSystemBase._on_set_world(...)
##  ↓ for - EcsRegistrarBase._on_system_before_ready()
##  ↓ for - EcsSystemBase._on_before_ready(...)
##  ↓ for - EcsSystemBase._on_ready(...)
##  ↓ for - EcsRegistrarBase._on_system_on_ready()
##  ## EcsWorld.update(...)
##  ↓ for - EcsSystemBase._on_pre_update(...)
##  ↓ for - EcsSystemBase._on_update(...)
##
class_name EcsWorld extends RefCounted

# ---------------------

## Used to delay system initialization,
## so that the system can access externally
## added commands and events during the initialization phase.
var _system_not_initialized := true

## Responsible for instantiating components
var _component_scanner: EcsComponentScanner

var _registrar_scanner: EcsRegistrarScanner

## All system instances
var _system_list: Array[EcsSystemBase]

## The expected number of cached entity_id.
## Due to the default function implementation,
## only the entity ID at the end is reclaimed,
## so the current variable is only a suggested value.
## Please refer to the function '_on_entity_unrecycled()' for details.
var _entity_id_pool_capacity: int

## Dictionary[ any, any ]
var _update_cache: Dictionary = {}

## Dictionary[ command_name: StringName, callable: Callable ]
var _command_dcit: Dictionary = {}

## Dictionary[ event_name:StringName, event_signal: Signal ]
var _event_dict: Dictionary = {}

# ---------------------

## Array[ ArrayIndex, entity_id:int ]
var _entity_id_pool: Array[int] = []

## Array[ ArrayIndex, entity:EcsEntity ]
var _entity_list: Array[EcsEntity] = []

## Array[ entity_id:ArrayIndex, components:Dictionary[ component_name:StringName, component:EcsComponentBase ] ]
var _entity_list_components: Array[Dictionary] = []

## Dictionary[ component_name:StringName, entity_id_list:Array[ ArrayIndex, entity_id:int ] ]
var _index__component_name_to_entity_id_list: Dictionary = {}


func _init(	component_scanner: EcsComponentScanner,
			system_scanner: EcsSystemScanner,
			registrar_scanner: EcsRegistrarScanner = null,
			entity_id_pool_capacity: int = 255) -> void:
	_component_scanner = component_scanner
	_registrar_scanner = registrar_scanner
	_entity_id_pool_capacity = entity_id_pool_capacity
	_system_list = system_scanner.load_system_list()
	_init_registrar_list()
	pass

func _init_registrar_list() -> void:
	if _registrar_scanner == null:
		return
	var registrar_list = _registrar_scanner.get_registrar_list()
	# _on_set_world
	for registrar in registrar_list:
		registrar._on_set_world(self)
		pass
	# _on_before_ready
	for registrar in registrar_list:
		registrar._on_before_ready()
		pass
	# _on_ready
	for registrar in registrar_list:
		registrar._on_ready()
		pass
	pass

## Trigger system initialization
##
## If you did not call the 'init_system()' function,
## it will be automatically called when the 'update()' function is called.
func init_system() -> void:
	if not _system_not_initialized:
		return
	_system_not_initialized = false
	# registrar_list
	var registrar_list: Array[EcsRegistrarBase]
	if _registrar_scanner != null:
		registrar_list = _registrar_scanner.get_registrar_list()
	else:
		registrar_list = []
	_registrar_scanner = null
	# Step 1.
	for system in _system_list:
		system._on_set_world(self)
	# Step 2.
	for registrar in registrar_list:
		registrar._on_system_before_ready()
	for system in _system_list:
		system._on_before_ready()
	# Step 3.
	for system in _system_list:
		system._on_ready()
	for registrar in registrar_list:
		registrar._on_system_on_ready()
	pass

func update(data = null) -> Dictionary:
	if _system_not_initialized:
		init_system()
	if data == null:
		data = _update_cache
		data.clear()
	assert(data is Dictionary, "The 'data' parameter must be of type Dictionary")
	# on_pre_update
	for i in _system_list.size():
		data = _system_list[-i]._on_pre_update(data)
	# on_update
	for system in _system_list:
		data = system._on_update(data)
	return data

func get_entity_list() -> Array[EcsEntity]:
	return _entity_list

func find_entity_first(component_name: StringName) -> EcsEntity:
	var entity_id_list = _index__component_name_to_entity_id_list.get(component_name)
	if entity_id_list == null or entity_id_list.is_empty():
		return null
	return entity_id_list[0]

func find_entity_list(component_name: StringName) -> Array[EcsEntity]:
	var out_entity_list: Array[EcsEntity] = []
	var entity_id_list = _index__component_name_to_entity_id_list.get(component_name)
	if entity_id_list == null:
		return out_entity_list
	for i in entity_id_list.size():
		var entity_id = entity_id_list[i]
		var entity = _entity_list[entity_id]
		assert(entity != null)
		out_entity_list.append(entity)
	return out_entity_list

func find_entity_list_append(component_name: StringName, out_entity_list: Array[EcsEntity]) -> void:
	var entity_id_list = _index__component_name_to_entity_id_list.get(component_name)
	if entity_id_list == null:
		return
	for i in entity_id_list.size():
		var entity_id = entity_id_list[i]
		var entity = _entity_list[entity_id]
		assert(entity != null)
		if not out_entity_list.has(entity):
			out_entity_list.append(entity)
	pass

func find_component_first(component_name: StringName) -> EcsComponentBase:
	var entity = find_entity_first(component_name)
	if entity == null:
		return null
	return entity.get_component(component_name)

func create_entity() -> EcsEntity:
	var entity: EcsEntity
	if _entity_id_pool.is_empty():
		var entity_id_next = _entity_list.size()
		entity = EcsEntity.new(self, entity_id_next)
		_entity_list.append(entity)
		_entity_list_components.append({})
	else:
		var entity_id = _entity_id_pool.pop_back()
		entity = _entity_list[entity_id]
		pass
	return entity

func _remove_entity(entity_id: int) -> void:
	_remove_component_all(entity_id)
	if not _recovery_entity(entity_id):
		# For entities that have not been recycled,
		# they will be placed in the cache for reuse
		var components = _entity_list_components[entity_id]
		components.clear()
		_entity_id_pool.append(entity_id)
	pass

func _recovery_entity(entity_id: int) -> bool:
	if _entity_id_pool.size() <= _entity_id_pool_capacity:
		return false
	var last_entity = _entity_list.back()
	if last_entity._entity_id == entity_id:
		# Because Array.resize() has high modification performance.
		# For example, viewing the Array.resize() function description
		# So Array.pop_back() should have the best performance in removing data elements.
		_entity_list.pop_back()
		_entity_list_components.pop_back()
		return true
	else:
		# Unable to recycle at optimal performance
		return _on_entity_unrecycled(entity_id)
	pass

## Triggered when entities cannot be recycled at optimal performance.
##
## The default is not to attempt to recycle the entity again,
## but to force it to be stored in the buffer pool.
##
## If you need to ensure that the entity is recycled,
## implement this method and return true,
## indicating that the entity has been recycled and cannot be placed in the cache.
## [override]
func _on_entity_unrecycled(entity_id: int) -> bool:
	return false

func _on_create_component_instantiate(component_name: StringName) -> Variant:
	if not _component_scanner.has_component_script(component_name):
		assert(false, "Class not find: component_name[" + component_name + "]")
		return null
	return _component_scanner.instantiate_component(component_name)

func _create_component(entity_id: int, component_name: StringName) -> EcsComponentBase:
	var component: EcsComponentBase = _on_create_component_instantiate(component_name)
	# ref
	var components = _get_components(entity_id)
	if components.has(component_name):
		push_error("Component are repeatedly added to the same entity: component_name[%s] entity_id[%s]" % \
		 [component_name, entity_id] \
		)
		assert(false, "Component are repeatedly added to the same entity: component_name[%s] entity_id[%s]" % \
		 [component_name, entity_id] \
		)
		# Although the data was returned, it has no association,
		# and even if the data is set, it will not have any effect,
		# just to prevent null pointers.
		return component
	components[component_name] = component
	component._entity_id = entity_id
	# index
	if not _index__component_name_to_entity_id_list.has(component_name):
		var new_index: Array[int] = []
		_index__component_name_to_entity_id_list[component_name] = new_index
	var index: Array[int] = _index__component_name_to_entity_id_list[component_name]
	index.append(entity_id)
	return component

func _get_components(entity_id: int) -> Dictionary:
	return _entity_list_components[entity_id]

func _remove_component(entity_id: int, component_name: StringName) -> bool:
	# ref
	var components = _get_components(entity_id)
	var component: EcsComponentBase = components.get(component_name)
	if component == null:
		return false
	component._entity_id = -1
	components.erase(component_name)
	# index
	var index: Array[int] = _index__component_name_to_entity_id_list[component_name]
	index.erase(entity_id)
	if index.is_empty():
		_index__component_name_to_entity_id_list.erase(component_name)
	return true

func _remove_component_all(entity_id: int) -> void:
	var components = _get_components(entity_id)
	for componentName in components.keys():
		_remove_component(entity_id, componentName)
	pass

func has_event(event_name: StringName) -> bool:
	return _event_dict.has(event_name)

func add_event(event_signal: Signal) -> bool:
	if has_event(event_signal.get_name()):
		assert(false, "Repeatedly adding event: " + str(event_signal))
		return false
	_event_dict[event_signal.get_name()] = event_signal
	return true

func get_event(event_name: StringName) -> Signal:
	var event_signal = _event_dict.get(event_name)
	assert(event_signal != null, "Not find event_signal: " + event_name)
	return event_signal

func remove_event(event_name: StringName) -> bool:
	return _event_dict.erase(event_name)

func has_command(command_name: StringName) -> bool:
	return _command_dcit.has(command_name)

func add_command(command_name: StringName, callable: Callable) -> bool:
	if has_command(command_name):
		assert(false, "Repeatedly adding command: " + command_name)
		return false
	_command_dcit[command_name] = callable
	return true

func remove_command(command_name: StringName) -> bool:
	return _command_dcit.erase(command_name)

func get_command(command_name: StringName) -> Callable:
	return _command_dcit[command_name]

func remove_system(system: EcsSystemBase) -> bool:
	var system_id = _system_list.find(system)
	if system_id == -1:
		return false
	return remove_system_by_id(system_id)

func remove_system_by_id(system_id: int) -> bool:
	if system_id >= 0 and system_id < _system_list.size():
		var system: EcsSystemBase = _system_list[system_id]
		_system_list.remove_at(system_id)
		_on_system_removed(system)
		return true
	else:
		return false

func remove_system_all() -> void:
	var size = _system_list.size()
	for i in size:
		remove_system_by_id(size - 1 - i)
	pass

func _on_system_removed(system: EcsSystemBase) -> void:
	system._on_removed()
	pass



func export_dict() -> Dictionary:
	var data: Dictionary = {}
	# Entity
	data["entity_id_pool"] = _entity_id_pool
	data["entity_id_capacity"] = _entity_list.size()
	# Component
	var component_name_list := _index__component_name_to_entity_id_list.keys()
	data["components"] = component_name_list
	data["components_list"] = _entity_list_components.map(
		__entity_list_components_to_dictionary.bind(component_name_list)
	)
	return data

func __entity_list_components_to_dictionary(components: Dictionary, component_name_list: Array) -> Dictionary:
	var data: Dictionary = {};
	for component_name in components:
		var component_name_index = component_name_list.find(component_name)
		data[component_name_index] = _component_scanner.component_to_dict(components[component_name])
	return data

func import_dict(data: Dictionary):
	# Entity
	_entity_id_pool.clear()
	_entity_id_pool.append_array(data["entity_id_pool"])
	var entity_id_capacity: int = data["entity_id_capacity"]
	if entity_id_capacity < _entity_list.size():
		_entity_list.resize(entity_id_capacity)
		pass
	elif entity_id_capacity > _entity_list.size():
		var entity_id_next = _entity_list.size()
		while entity_id_next < entity_id_capacity:
			_entity_list.append(EcsEntity.new(self, entity_id_next))
			entity_id_next += 1
		pass
	# Component
	var component_name_list: Array = data["components"]
	var components_list: Array = data["components_list"]
	_entity_list_components.clear()
	_entity_list_components.append_array(
		components_list.map(__dictionary_to_entity_list_components.bind(component_name_list))
	)
	pass

func __dictionary_to_entity_list_components(data: Dictionary, component_name_list: Array) -> Dictionary:
	var components: Dictionary = {}
	var index: int
	var component_name: String
	for component_name_index in data:
		# component_name_index:int to component_name:String
		index = int(component_name_index)
		assert(index < component_name_list.size(), "Import data error, non-existent component name index: " + str(component_name_index))
		component_name = component_name_list[index]
		var component_data = data[component_name_index]
		# instantiate component
		var component = _component_scanner.dict_to_component(component_name, component_data)
		components[component_name] = component
		# index
		if not _index__component_name_to_entity_id_list.has(component_name):
			_index__component_name_to_entity_id_list[component_name] = []
		_index__component_name_to_entity_id_list[component_name].append(component._entity_id)

	return components

