# GDScript ECS 框架

	警告：本ECS框架，仅适合分离复杂数据计算的逻辑。
	对于动画等游戏渲染以及相关的控制脚本，你应该使用Godot的节点。
	并通过ECS框架的命令和事件，将ECS的世界与你的渲染节点关联起来。

![中文 GDScript ECS 架构图](https://github.com/yihrmc/gdscript-ecs/assets/40130751/11c54f1a-dfd0-4d16-aeae-86b28bf4d27b)


## 框架特点

1. 所有的ECS组件，都支持语法提示。每个组件都是GDScript自定义类。

2. 查询实体非常快。实体ID是数组索引。

3. 添加和删除实体依然也非常快。这是因为框架使用了缓存池，实现对实体的重复使用。

4. 支持序列化，导入数据和导出数据，而不需要任何配置。并且数据非常紧凑。

5. 使用起来非常的简洁，逻辑清晰。


## 什么是ECS架构

ECS全称Entity-Component-System,即实体-组件-系统。是一种软件架构，主要用于游戏开发。


## 了解框架

框架有三个主要元素组成，分别是`Entity`、`Component`和`System`。另外还有`Event`和`Command`两个元素，辅助`System`元素完成代码逻辑。

- `Entity` 实体：是组件的容器，一个实体包含多个组件，实体本身不负责存储数据。
- `Component` 组件：负责存储数据。其行为与Dictionary作用相同。
- `System` 系统：逻辑处理。
- `Event` 事件：一个人抛出事件，可以多个人(也可以没人)监听事件。抛出事件后，没有结果。其实现，就是Godot的信号。
- `Command` 命令：一个人调用命令，一个人执行命令。命令允许返回结果。其实现，就是一个函数。

## 例子
```gdscript
static func test():
	# 添加组件脚本
	var component_scanner = EcsComponentScanner.new()
	component_scanner.add_script(Component_Namer)
	component_scanner.add_script(Component_Test2)
	# component_scanner.add_script(load("Component_xxxx.gd"))
	# component_scanner.scan_script("res://gdscript_ecs_test/component/", "*.gd")

	# 添加系统脚本
	var system_scanner = EcsSystemScanner.new()
	system_scanner.add_script(System_Test1)
	system_scanner.add_script(System_Test2)
	# system_scanner.add_script(load("System_xxxx1.gd"))
	# system_scanner.scan_script("res://gdscript_ecs_test/system/", "*.gd")

	# 初始化世界
	var world := EcsWorld.new(component_scanner, system_scanner)
	world.init_system() # 可选的

	world.add_command("test_world_print", func(arg):
		print("[world1_print]", arg)
		pass)

	# 你可以任何地方创建实体，例如在这里创建实体
	var entity = world.create_entity()
	var entity_namer = entity.create_component(Component_Namer.NAME) as Component_Namer
	entity_namer.display_name = "Entities created in any location"

	# 让所有系统处理数据
	for i in 15:
		world.update({
			count = i + 1
		})

	# 导出数据到存档
	var world_data = world.export_dict()
	var world_data_json_str = JSON.stringify(world_data, "\t")
	print("[世界1的存档数据] ", world_data_json_str)

	# 从存档导入数据到一个新的世界
	var world2 := EcsWorld.new(component_scanner, system_scanner)
	var world_data_json = JSON.parse_string(world_data_json_str)
	world2.import_dict(world_data_json)
	print("[世界2的存档数据] ", JSON.stringify(world_data_json, "\t"))

	# 导入数据到世界中，必须确保世界具有相同的命令和事件
	#
	# 你认为这样同步很麻烦吗？
	# 您可以使用`EcsRegisterScanner`类，来实现仅创建命令和事件的功能。
	#
	world2.add_command("test_world_print", func(arg):
		print("[world2_print]", arg)
		pass)

	# 世界已经完全恢复，你可以随心所欲地调用它。
	world2.update({
		count = 1
	})
	pass

## 为实体提供命名数据
class Component_Namer extends EcsComponentBase:
	const NAME = &"Namer"
	## Display Name
	var display_name: String = ""

## 第二个测试组件
class Component_Test2 extends EcsComponentBase:
	const NAME = &"Test2"
	var count: int = -1

## 一个测试系统
class System_Test1 extends EcsSystemBase:
	signal on_entity_created()

	func _on_before_ready() -> void:
		add_system_event(on_entity_created)
		pass

	func _on_update(downlink_data: Dictionary) -> Dictionary:
		if downlink_data.count == 10:
			# Create entities in the system
			var entity = world.create_entity()

			var namer = entity.create_component(Component_Namer.NAME) as Component_Namer
			namer.display_name = "Test1 Entity - " + str(downlink_data.count)

			var component2 = entity.create_component(Component_Test2.NAME) as Component_Test2
			component2.count = downlink_data.count

			downlink_data.count = 11111111111111
			on_entity_created.emit()
			pass
		return downlink_data
	pass

## 第二个测试系统
class System_Test2 extends EcsSystemBase:

	func _on_ready() -> void:
		# 连接来自其它地方注册的信号
		get_event("on_entity_created").connect(__on_entity_created)
		pass

	func __on_entity_created():
		print("[系统2] 收到信号，系统1创建了实体")
		pass

	func _on_update(downlink_data: Dictionary) -> Dictionary:
		var text = "[系统2] downlink_data.count: " + str(downlink_data.count)
		get_command("test_world_print").call(text)
		return downlink_data
	pass
```
