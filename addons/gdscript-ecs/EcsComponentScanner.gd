class_name EcsComponentScanner extends _EcsGDScriptScanner

var _component_name_constant: StringName
var _component_script_dict: Dictionary = {}

func _init(component_base_script: Script = null, component_name_constant: StringName = EcsComponentBase.COMPONENT_NAME_CONSTANT_NAME) -> void:
	super(component_base_script if component_base_script != null else EcsComponentBase)
	_component_name_constant = component_name_constant

func add_script(component_script: GDScript) -> void:
	if not _is_script(component_script):
		return
	if not component_script.get_script_constant_map().has(_component_name_constant):
		return
	var component_name = get_component_name(component_script)
	if has_component_script(component_name):
		return
	_component_script_dict[component_name] = component_script
	pass

func has_component_script(component_name: StringName) -> bool:
	return _component_script_dict.has(component_name)

func get_component_name(component_script: GDScript) -> StringName:
	return component_script.get_script_constant_map().get(_component_name_constant)

func instantiate_component(component_name: StringName) -> EcsComponentBase:
	var component_script: GDScript = _component_script_dict.get(component_name)
	return component_script.new()

func component_to_dict(component: EcsComponentBase) -> Dictionary:
	var data: Dictionary = {}
	var property_name_list = component.get_property_name_list()
	for property_name in property_name_list:
		data[property_name] = component.get_property_value(property_name)
	return data

func dict_to_component(component_name: StringName, data: Dictionary) -> EcsComponentBase:
	var component := instantiate_component(component_name)
	var property_name_list := component.get_property_name_list()
	for property_name in property_name_list:
		if not data.has(property_name):
			continue
		component.set_property_value(property_name, data[property_name])
		pass
	return component
