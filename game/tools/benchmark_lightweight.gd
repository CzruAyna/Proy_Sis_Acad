extends SceneTree
const World = preload("res://scripts/campus_world.gd")
const Cave = preload("res://scripts/menu_cave.gd")


func _initialize() -> void:
	var world := World.new()
	var start := Time.get_ticks_usec()
	var allowed := 0
	for i in range(5000):
		var point := Vector2(30 + posmod(i * 173, 12200), 30 + posmod(i * 347, 8600))
		allowed += int(world._can_stand_outside(point))
	var collision_us := Time.get_ticks_usec() - start
	start = Time.get_ticks_usec()
	var cells := 0
	for i in range(120):
		cells += Cave.frame(Rect2(24, 24, 880, 620), 32, 24, i / 20.0)["cells"].size()
	var result := {"cpu": OS.get_processor_name(), "collision_queries": 5000, "allowed": allowed, "collision_us": collision_us, "cave_frames": 120, "cave_cells": cells, "cave_us": Time.get_ticks_usec() - start}
	print("LIGHTWEIGHT_BENCHMARK ", JSON.stringify(result))
	var args := OS.get_cmdline_user_args()
	if args.size() == 1:
		var file := FileAccess.open(args[0], FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(result, "\t"))
	world.free()
	quit()
