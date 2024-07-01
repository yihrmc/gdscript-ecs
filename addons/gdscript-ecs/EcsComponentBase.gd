## Component
class_name EcsComponentBase extends RefCounted

## Constant name of component name
##
## Used in EcsComponentScanner.gd
const COMPONENT_NAME_CONSTANT_NAME: StringName = "NAME"

## The ID of the entity to which the component
var _entity_id: int = -1

## [override]
func is_hide_all_properties() -> bool:
	return false

## [override]
func get_property_name_list_of_hidden() -> PackedStringArray:
	return []

## [override]
func get_property_name_list() -> PackedStringArray:
	if is_hide_all_properties():
		return []
	var property_name_list_of_hidden := get_property_name_list_of_hidden()
	var property_name_list: PackedStringArray = []
	var property_list = get_property_list()
	for property in property_list:
		if property_name_list_of_hidden.has(property.name):
			continue
		if (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			property_name_list.append(property.name)
	return property_name_list

## [override]
func get_property_value(property_name: StringName) -> Variant:
	return get(property_name)

## [override]
func set_property_value(property_name: StringName, property_value: Variant) -> void:
	set(property_name, property_value)

