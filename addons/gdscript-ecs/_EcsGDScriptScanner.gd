## GDScript Scanner
##
## Find and load scripts from certain directories
##
class_name _EcsGDScriptScanner extends RefCounted

var _base_script: Script

func _init(base_script: Script = null) -> void:
	_base_script = base_script

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

func add_script(_script: GDScript) -> void:
	assert(false, "Please re implement this function: 'add_component_script'")
	pass

func _is_script(script: GDScript) -> bool:
	if not script.can_instantiate():
		return false
	if not _is_parent_script(script, _base_script):
		return false
	return true

func _is_parent_script(child_script: Script, parent_script: Script) -> bool:
	var base_script: Script = child_script.get_base_script()
	while base_script != null:
		if base_script == parent_script:
			return true
		base_script = base_script.get_base_script()
		pass
	return false
