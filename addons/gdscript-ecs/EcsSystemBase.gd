## System
class_name EcsSystemBase extends RefCounted

var _ref_world: WeakRef
var bind_event_name_list: Array[StringName] = []
var bind_command_name_list: Array[StringName] = []

var world: EcsWorld:
	get:
		return _ref_world.get_ref()


## Step 0.
## When registering the system, this function will be called before '_on'beforeready'.
func _on_set_world(ecs_world: EcsWorld):
	_ref_world = weakref(ecs_world)

## Step 1.
## Preparing to register the system.
##
## At this stage, it is suitable to call
## the 'add_system_command()' function to register events.
## [override]
func _on_before_ready() -> void:
	pass

## Step 2.
## Indicates that all systems have been registered and completed.
##
## At this stage, it is suitable to listen to signals registered with other systems.
## [override]
func _on_ready() -> void:
	pass

## Step 3.
## [override]
func _on_pre_update(uplink_data: Dictionary) -> Dictionary:
	return uplink_data

## Step 4.
## [override]
func _on_update(downlink_data: Dictionary) -> Dictionary:
	return downlink_data

## Step 5.
## [override]
func _on_removed() -> void:
	for event_name in bind_event_name_list:
		remove_system_event(event_name)
	for command_name in bind_command_name_list:
		remove_system_command(command_name)
	pass


func has_event(event_name: StringName) -> bool:
	return world.has_event(event_name)

func add_system_event(event_signal: Signal) -> void:
	if world.add_event(event_signal):
		bind_event_name_list.append(event_signal.get_name())

func remove_system_event(event_name: StringName) -> bool:
	if not bind_event_name_list.has(event_name):
		return false
	bind_event_name_list.erase(event_name)
	return world.remove_event(event_name)

func get_event(event_name: StringName) -> Signal:
	return world.get_event(event_name)

func event(event_name: StringName) -> Signal:
	return world.get_event(event_name)


func has_command(command_name: StringName) -> bool:
	return world.has_command(command_name)

func add_system_command(command_name: StringName, callable: Callable) -> void:
	if world.add_command(command_name, callable):
		bind_command_name_list.append(command_name)

func remove_system_command(command_name: StringName) -> bool:
	if not bind_command_name_list.has(command_name):
		return false
	bind_command_name_list.erase(command_name)
	return world.remove_command(command_name)

func get_command(command_name: StringName) -> Callable:
	return world.get_command(command_name)

func command(command_name: StringName) -> Callable:
	return world.get_command(command_name)


