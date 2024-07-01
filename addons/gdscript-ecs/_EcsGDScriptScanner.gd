## GDScript Scanner
##
## Find and load scripts from certain directories
##
class_name _EcsGDScriptScanner extends RefCounted

func _init() -> void:
	pass

## Scan all scripts in the specified directory
##
## All script files in the upper directory must be loaded before those in the subdirectories.
## Therefore, for example, by scanning system scripts,
## you can achieve sequential loading of system scripts based on the hierarchy of directories.
func scan_script(path: String, file_name_expr: String = "*.gd", include_sub_paths: bool = true) -> Error:
	var dir = DirAccess.open(path)
	if dir == null:
		return DirAccess.get_open_error()
	dir.list_dir_begin()
	var dir_name_list: PackedStringArray = []
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			if include_sub_paths:
				dir_name_list.append(file_name)
		else:
			if not file_name.match(file_name_expr):
				continue
			var script = load(path + "/" + file_name) as GDScript
			assert(script != null, "Unable to load script: " + path + "/" + file_name)
			if script != null:
				add_script(script)
			pass
		pass
	dir.list_dir_end()
	# Load all scripts in the directory first, then scan the subdirectories.
	for dir_name in dir_name_list:
		scan_script(path + "/" + dir_name, file_name_expr, true)
	return OK

func add_script(_script: GDScript) -> bool:
	assert(false, "Please re implement this function: 'add_script'")
	return false

func _is_parent_script(child_script: Script, parent_script: Script) -> bool:
	var base_script: Script = child_script.get_base_script()
	while base_script != null:
		if base_script == parent_script:
			return true
		base_script = base_script.get_base_script()
		pass
	return false

func _is_expected_script_structure(script: GDScript, script_structure: Dictionary) -> bool:
	# instantiate
	if script_structure.has("instantiate"):
		if script.can_instantiate() != script_structure.instantiate:
			return false
	# constant name
	if script_structure.has("constant_name_list"):
		var script_constant_map := script.get_script_constant_map()
		for constant_name in script_structure.constant_name_list:
			if not script_constant_map.has(constant_name):
				return false
	# method
	if script_structure.has("methods"):
		var methods = script_structure.methods
		for method_structure in methods:
			var script_method = _find_script_method(script, method_structure.name)
			if script_method == null:
				return false
			if method_structure.has("type"):
				if method_structure.type != script_method.type:
					return false
			if method_structure.has("flags"):
				if (script_method.flags & method_structure.flags) == 0:
					return false
			pass
		pass
	# property
	if script_structure.has("properties"):
		var properties = script_structure.properties
		for property_structure in properties:
			var script_property = _find_script_property(script, property_structure.name)
			if script_property == null:
				return false
			if property_structure.has("class_name"):
				if property_structure.class_name != script_property.class_name:
					return false
				pass
			if property_structure.has("type"):
				if property_structure.type != script_property.type:
					return false
			if property_structure.has("usage"):
				if (script_property.usage & property_structure.usage) == 0:
					return false
			pass
		pass
	# signal
	if script_structure.has("signals"):
		var signals = script_structure.signals
		for signal_structure in signals:
			var script_signal = _find_script_signal(script, signal_structure.name)
			if script_signal == null:
				return false
			if signal_structure.has("type"):
				if signal_structure.type != script_signal.type:
					return false
			if signal_structure.has("flags"):
				if (script_signal.flags & signal_structure.flags) == 0:
					return false
			pass
	return true

## return null or {
##		name: String,
##		args: Array,
##		default_args: Array,
##		flags: MethodFlags,
##		id: int,
##		return: Dictionary
## }
func _find_script_method(script: GDScript, method_name: String):
	var script_method_list := script.get_script_method_list()
	for script_method in script_method_list:
		if script_method.name == method_name:
			return script_method
	return null

## return null or {
##		name: String,
##		class_name: StringName,
##		type: int(Variant.Type),
##		hint: PropertyHint,
##		hint_string,
##		usage: PropertyUsageFlags
## }
func _find_script_property(script: GDScript, property_name: String):
	var script_property_list := script.get_script_property_list()
	for script_property in script_property_list:
		if script_property.name == property_name:
			return script_property
	return null

## return null or {
##		name: String,
##		args: Array,
##		default_args: Array,
##		flags: MethodFlags,
##		id: int,
##		return: Dictionary
## }
func _find_script_signal(script: GDScript, signal_name: String):
	var script_signal_list = script.get_script_signal_list()
	for script_signal in script_signal_list:
		if script_signal.name == signal_name:
			return script_signal
	return null
