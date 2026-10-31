extends Node
## One low-frequency clock for visible panels; no timers per card.
var surfaces: Array[Dictionary] = []
var actors: Array[WeakRef] = []
var elapsed := 0.0
var tick := 0.0
var running := false


func configure(animations: bool, economical: bool) -> void:
	running = animations and not economical
	set_process(running)
	if not running:
		for entry in surfaces:
			var owner = entry["owner"].get_ref()
			entry["style"].terminal_phase = -1
			if is_instance_valid(owner):
				owner.queue_redraw()
		for reference in actors:
			var actor = reference.get_ref()
			if is_instance_valid(actor):
				actor.advance_effects(-1)


func clear() -> void:
	surfaces.clear()
	actors.clear()
	elapsed = 0
	tick = 0


func register(owner: Control, style: StyleBox) -> void:
	surfaces.append({"owner": weakref(owner), "style": style})
	style.terminal_phase = elapsed if running else -1


func register_actor(actor: Control) -> void:
	actors.append(weakref(actor))
	actor.advance_effects(elapsed if running else -1)


func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	tick += delta
	if tick < (0.05 if not actors.is_empty() else 0.16):
		return
	tick = 0
	var live: Array[Dictionary] = []
	for entry in surfaces:
		var owner = entry["owner"].get_ref()
		if not is_instance_valid(owner) or not owner.is_inside_tree():
			continue
		live.append(entry)
		if owner.is_visible_in_tree() and owner.get_global_rect().intersects(owner.get_viewport_rect()):
			entry["style"].terminal_phase = elapsed
			owner.queue_redraw()
	surfaces = live
	var live_actors: Array[WeakRef] = []
	for reference in actors:
		var actor = reference.get_ref()
		if not is_instance_valid(actor) or not actor.is_inside_tree():
			continue
		live_actors.append(reference)
		if actor.is_visible_in_tree():
			actor.advance_effects(elapsed)
	actors = live_actors
