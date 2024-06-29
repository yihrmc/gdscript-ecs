class_name EcsSystemScanner extends _EcsGDScriptScanner

## Array[ ArrayIndex, system_script:GDScript ]
var _system_script_list: Array[GDScript] = []

func _init(system_base_script: Script = null) -> void:
	super(system_base_script if system_base_script != null else EcsSystemBase)
	pass

func add_script(script: GDScript) -> void:
	if not _is_script(script):
		return
	_system_script_list.append(script)

## Instantiate all systems
func load_system_list() -> Array[EcsSystemBase]:
	var system_list: Array[EcsSystemBase] = []
	for system_script in _system_script_list:
		var system = system_script.new()
		system_list.append(system)
	return system_list
