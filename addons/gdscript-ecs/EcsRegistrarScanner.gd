## Registrar
##
## Sometimes you only need to add events and commands without dealing with 'EcsSystemBase._on_update()',
## so you don't need to add a system, but just a registrar.
##
class_name EcsRegistrarScanner extends _EcsGDScriptScanner

var _registrar_base_script: Script

## Array[EcsRegistrarBase | '... Duck Type']
var _registrar_list: Array = []

func _init(registrar_base_script: Script = null) -> void:
	_registrar_base_script = EcsRegistrarBase if registrar_base_script == null else registrar_base_script
	pass

func add_script(script: GDScript) -> bool:
	if not _is_parent_script(script, _registrar_base_script):
		return false
	var registrar = script.new()
	_registrar_list.append(registrar)
	return true

func add_registrar(registrar: EcsRegistrarBase) -> void:
	assert(registrar != null, "registrar is null")
	_registrar_list.append(registrar)

func get_registrar_list() -> Array:
	return _registrar_list
