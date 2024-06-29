extends Control
class_name Test

var _world: EcsWorld

class Component_InnerClassTest1 extends EcsComponentBase:
	const NAME := &"InnerClassTest1"
	var var1: String = "Tom"
	var xxx2: int = 123
	pass

class System_InnerClassTest1 extends EcsSystemBase:
	pass

func _ready() -> void:
	print("[gdscript_ecs_test]")

	# Component
	var component_scanner = EcsComponentScanner.new()
	# From internal class
	component_scanner.add_script(Component_InnerClassTest1)
	# From external class
	component_scanner.add_script(Component_ExternalClassTest2)
	# Scan and load scripts from directory
	component_scanner.scan_script("res://gdscript_ecs_test/component", "*.gd")
	# Console output：
	#
	# [component_scanner] All components: ["InnerClassTest1", "ExternalClassTest2", "TestRoot1", "TestRoot2", "TestChild1", "TestChild2"]
	#
	print("[component_scanner] All components: ",
		component_scanner._component_script_dict.keys())

	# System
	var system_scanner = EcsSystemScanner.new()
	# From internal class
	system_scanner.add_script(System_InnerClassTest1)
	# ...
	# The scanning method for system scripts is the same as that for component scripts,
	# so no examples will be added.
	# ...
	# Scanning the directory is orderly.
	system_scanner.scan_script("res://gdscript_ecs_test/system/", "*.gd")
	# Console output：
	#
	#   [system_scanner] System quantity: 7
	#
	print("[system_scanner] System quantity: ", system_scanner._system_script_list.size())

	_world = EcsWorld.new(component_scanner, system_scanner)

	# Console output：
	#
	#	[world.init_system()]
	#	[EcsSystem][System_Root1.gd] hello
	#	[EcsSystem][System_Root2.gd] hello
	#	[EcsSystem][System_Child1.gd] hello
	#	[EcsSystem][System_Child2.gd] hello
	#	[EcsSystem][System_Grandson1.gd] hello
	#	[EcsSystem][System_Grandson2.gd] hello
	#
	print("[world.init_system()]")
	_world.init_system()

	# Console output：
	#
	#	[world.update(...)]
	#	[EcsSystem][System_Root1.gd] _on_update: { "opt": 1 }
	#	[EcsSystem][System_Root2.gd] _on_update: { "opt": 1 }
	#	[EcsSystem][System_Child1.gd] _on_update: { "opt": 1 }
	#	[EcsSystem][System_Child2.gd] _on_update: { "opt": 1 }
	#	[EcsSystem][System_Grandson1.gd] _on_update: { "opt": 1 }
	#	[EcsSystem][System_Grandson2.gd] _on_update: { "opt": 1 }
	#
	print("[world.update(...)]")
	_world.update({
		opt = 1
	})
	pass
