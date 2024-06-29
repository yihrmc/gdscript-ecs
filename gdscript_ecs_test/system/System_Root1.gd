extends EcsSystemBase

func _on_ready() -> void:
	print("[EcsSystem][System_Root1.gd] hello")

func _on_update(downlink_data: Dictionary) -> Dictionary:
	print("[EcsSystem][System_Root1.gd] _on_update: ", downlink_data)
	return downlink_data
