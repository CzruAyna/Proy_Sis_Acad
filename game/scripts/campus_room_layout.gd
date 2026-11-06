extends RefCounted
## Illustrative proportions, not a surveyed institutional floor plan.
static var _cache: Dictionary = {}


static func make(kind: String, id: String, room: String) -> Dictionary:
	var key := id + "/" + room
	if _cache.has(key):
		return _cache[key]
	var variant := posmod(key.hash(), 4)
	var extent := Vector2(576, 416)
	if kind == "classroom":
		extent = [Vector2(640, 400), Vector2(480, 560), Vector2(704, 448), Vector2(576, 416)][variant]
	elif kind == "computer_lab":
		extent = Vector2(672, 448) if variant % 2 == 0 else Vector2(576, 544)
	elif kind in ["physics_lab", "chemistry_lab", "lab"]:
		extent = Vector2(768, 480) if kind == "chemistry_lab" else Vector2(640, 480)
	elif kind == "physics_virtual":
		extent = Vector2(640, 416)
	elif kind == "library":
		extent = Vector2(608, 480)
	elif kind == "office":
		extent = Vector2(560, 400)
	elif kind == "social":
		extent = Vector2(720, 480) if id == "comedor" else Vector2(576, 416)
	elif kind == "games_room":
		extent = Vector2(480, 320) # Preserve the minigame interaction stations.
	var items: Array[Dictionary] = []
	var center := extent.x / 2
	if kind in ["classroom", "computer_lab", "physics_virtual"]:
		var shared := kind == "classroom" and variant == 2
		for y in range(128, int(extent.y - 90), 64):
			for side in [-1, 1]:
				if shared:
					_add(items, "bench", Rect2(center - 254 if side < 0 else center + 78, y, 176, 38))
				else:
					for col in range(2):
						var x := center - 174 + col * 68 if side < 0 else center + 62 + col * 68
						_add(items, "computer" if kind != "classroom" else "desk", Rect2(x, y, 48, 34))
	elif kind in ["physics_lab", "chemistry_lab", "lab"]:
		for y in range(132, int(extent.y - 90), 76):
			for side in [-1, 1]:
				_add(items, "experiment", Rect2(center - 222 if side < 0 else center + 82, y, 140, 42))
	elif kind == "library":
		for x in [54, 136, 414, 496]:
			_add(items, "books", Rect2(x, 112, 48, 196))
		_add(items, "bench", Rect2(56, 356, 142, 38))
		_add(items, "bench", Rect2(410, 356, 142, 38))
	elif kind == "office":
		_add(items, "counter", Rect2(60, 140, 148, 42))
		_add(items, "counter", Rect2(352, 140, 148, 42))
		_add(items, "cabinet", Rect2(52, 216, 42, 78))
		_add(items, "bench", Rect2(376, 270, 108, 36))
	elif kind == "social":
		if id == "comedor":
			for y in [140, 236, 332]:
				_add(items, "bench", Rect2(70, y, 192, 42))
				_add(items, "bench", Rect2(458, y, 192, 42))
		else:
			_add(items, "counter", Rect2(56, 140, 152, 42))
			_add(items, "bench", Rect2(370, 206, 140, 42))
			_add(items, "cabinet", Rect2(60, 234, 40, 72))
	if kind in ["computer_lab", "physics_virtual", "physics_lab", "chemistry_lab", "lab"]:
		_add(items, "rack" if kind in ["computer_lab", "physics_virtual"] else "cabinet", Rect2(extent.x - 74, 44, 30, 44))
	if kind == "chemistry_lab":
		_add(items, "hood", Rect2(54, 46, 94, 34))
	elif kind == "physics_lab":
		_add(items, "experiment", Rect2(54, 46, 140, 34))
	elif id == "posta":
		_add(items, "bed", Rect2(340, 126, 160, 54))
	var obstacles: Array[Rect2] = []
	for item in items:
		obstacles.append(item["rect"])
	var layout := {"kind": kind, "id": id, "variant": variant, "size": extent, "items": items, "obstacles": obstacles,
		"spawn": Vector2(center, extent.y - 42), "exit": Vector2(center, extent.y - 34), "provisional": true}
	_cache[key] = layout
	return layout


static func _add(items: Array[Dictionary], kind: String, rect: Rect2) -> void:
	items.append({"kind": kind, "rect": rect})
