## Registrar
##
## Sometimes you only need to add events and commands without dealing with 'EcsSystemBase._on_update()',
## so you don't need to add a system, but just a registrar.
##
class_name EcsRegistrarScanner extends _EcsGDScriptScanner

var _registrar_list: Array[EcsRegistrarBase] = []

func _init(registrar_base_script: Script = null) -> void:
	super(registrar_base_script if registrar_base_script != null else EcsRegistrarBase)
	pass

func add_script(script: GDScript) -> void:
	if not _is_script(script):
		return
	var registrar = script.new()
	_registrar_list.append(registrar)

func get_registrar_list() -> Array[EcsRegistrarBase]:
	return _registrar_list
