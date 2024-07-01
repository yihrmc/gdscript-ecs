##
## Main scene, the game starts from here
##
extends Node

## The logical world of games
var _world: EcsWorld

## Size of the game window.
var _screen_size

func _ready() -> void:
	_screen_size = $WorldContainer.get_viewport_rect().size
	_init_ecs()
	pass

func _init_ecs() -> void:
	# Register all components
	var component_scanner = EcsComponentScanner.new()
	component_scanner.scan_script("res://gdscript_ecs_test/ecs/components/", "*.gd")
	# Register all systems
	var system_scanner = EcsSystemScanner.new()
	system_scanner.scan_script("res://gdscript_ecs_test/ecs/systems/", "*.gd")
	# Register events and commands
	var registrar_scanner = EcsRegistrarScanner.new()
	#registrar_scanner.add_registrar_node($ECSBinder_Player)
	# ECS World
	_world = EcsWorld.new(component_scanner, system_scanner, registrar_scanner)
	# Bind with Godot node
	_world.add_command("create_player_node", create_player_node)
	_world.add_command("create_mob_node", create_mob_node)
	# ECS Init all systems
	_world.init_system()

	# Test
	_world.get_command("create_player_entity").call()
	for i in 10:
		_world.get_command("create_mob_entity").call()
	pass

func _process(delta: float) -> void:
	_world.update({
		process_delta = delta,
		screen_size = _screen_size,
	})

func create_player_node():
	var Scene_Player = load("res://gdscript_ecs_test/node/Player.tscn")
	var player_node = Scene_Player.instantiate()
	player_node._world = _world
	$WorldContainer.add_child(player_node)
	return player_node

func create_mob_node():
	var Scene_Mob = load("res://gdscript_ecs_test/node/Mob.tscn")
	var mob_node = Scene_Mob.instantiate()
	mob_node._world = _world
	$WorldContainer.add_child(mob_node)
	return mob_node
