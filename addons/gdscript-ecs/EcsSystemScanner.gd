class_name EcsSystemScanner extends _EcsGDScriptScanner

var _system_base_script: Script

## Array[ ArrayIndex, system_script:GDScript ]
var _system_script_list: Array[GDScript] = []

func _init(system_base_script: Script = null) -> void:
	_system_base_script = EcsSystemBase if system_base_script == null else system_base_script
	pass

func add_script(script: GDScript) -> bool:
	if not _is_parent_script(script, _system_base_script):
		return false
	_system_script_list.append(script)
	return true

## Instantiate all systems
func load_system_list() -> Array[EcsSystemBase]:
	var system_list: Array[EcsSystemBase] = []
	for system_script in _system_script_list:
		var system = system_script.new()
		system_list.append(system)
	return system_list
