## EcsCommandRegistrarBase
## - Register commands or events before EcsSystem initialization.
class_name EcsRegistrarBase
extends RefCounted

var _ref_world: WeakRef

var world: EcsWorld:
	get:
		return _ref_world.get_ref()

func _on_set_world(ecs_world: EcsWorld):
	_ref_world = weakref(ecs_world)

## Step 1.
## [override]
func _on_before_ready() -> void:
	pass

## Step 2.
## [override]
func _on_ready() -> void:
	pass

## Step 3.
## [override]
func _on_system_before_ready() -> void:
	pass

## Step 3.
## [override]
func _on_system_on_ready() -> void:
	pass


func has_event(event_name: StringName) -> bool:
	return world.has_event(event_name)

func add_event(event_signal: Signal) -> void:
	world.add_event(event_signal)

func remove_event(event_name: StringName) -> bool:
	return world.remove_event(event_name)

func get_event(event_name: StringName) -> Signal:
	return world.get_event(event_name)

func event(event_name: StringName) -> Signal:
	return world.get_event(event_name)


func has_command(command_name: StringName) -> bool:
	return world.has_command(command_name)

func add_command(command_name: StringName, callable: Callable) -> void:
	world.add_command(command_name, callable)

func get_command(command_name: StringName) -> Callable:
	return world.get_command(command_name)

func command(command_name: StringName) -> Callable:
	return world.get_command(command_name)

