extends RefCounted

const DAY := 1440
const WEEK := 7 * DAY
const START := 540.0
const ALLOWANCE := 100
const CAPACITY := 12
const TRAITS := ["Miopía", "Intolerancia a la lactosa", "Cabeza de pollo"]
const GEAR := {"lentes": "Lentes para leer la pizarra", "agenda": "Agenda de bolsillo"}
const ITEMS := {
	"lentes": ["Lentes", 10, 0, 0], "agenda": ["Agenda", 5, 0, 0],
	"leche": ["Leche", 4, 10, 25], "sin_lactosa": ["Leche sin lactosa", 4, 10, 25],
	"agua": ["Agua", 0, 0, 45], "pollo": ["Porción de pollo", 9, 58, 0],
	"milanesa": ["Sándwich de milanesa", 7, 48, 2], "cafe": ["Café espumoso", 4, 4, 25],
	"jugo": ["Jugo", 3, 4, 37], "pan": ["Pan", 3, 25, 0],
	"gaseosa": ["Gaseosa", 4, 2, 30], "licor": ["Licor", 12, 0, 0],
	"almuerzo": ["Almuerzo del comedor", 6, 55, 12]
}
const VENDORS := {
	"comedor": ["Comedor FNI", "Dentro del campus · junto a la puerta del comedor", ["almuerzo", "agua"]],
	"kiosco": ["Kiosco del campus", "Dentro del campus · junto al ingreso principal", ["pan", "jugo", "agua", "leche", "sin_lactosa"]],
	"pollo": ["Puesto de pollo", "Fuera del campus · cruza el ingreso principal", ["pollo", "agua"]],
	"cafe": ["Café espumoso", "Fuera del campus · por la acera del ingreso", ["cafe", "pan", "agua"]],
	"tienda": ["Tienda y licorería", "Fuera del campus · por la acera del ingreso", ["gaseosa", "jugo", "agua", "licor", "lentes", "agenda"]],
	"camion": ["Camión de milanesas", "Fuera del campus · frente al ingreso, hacia el norte", ["milanesa", "jugo", "agua"]]
}

var student_trait := ""
var equipment: Dictionary = {}
var shops: Dictionary = {}
var minutes := START
var balance := ALLOWANCE
var hunger := 0.0
var thirst := 0.0
var backpack: Dictionary = {}
var tasks: Dictionary = {}
var notes: Dictionary = {}


func restore(data: Variant) -> void:
	var stored: Dictionary = data if data is Dictionary else {}
	student_trait = str(stored.get("student_trait", ""))
	if student_trait not in TRAITS:
		student_trait = ""
	equipment = {}
	for id in GEAR:
		if stored.get("equipment") is Dictionary and stored["equipment"].get(id) == true:
			equipment[id] = true
	shops = stored["shops"].duplicate() if stored.get("shops") is Dictionary else {}
	minutes = _number(stored.get("minutes"), START, START, 1000000000.0)
	balance = int(_number(stored.get("balance"), ALLOWANCE, 0.0, 1000000000.0))
	hunger = _number(stored.get("hunger"), 0.0, 0.0, 100.0)
	thirst = _number(stored.get("thirst"), 0.0, 0.0, 100.0)
	backpack.clear()
	var stock: Variant = stored.get("backpack")
	if stock is Dictionary:
		for id in ITEMS:
			var count := int(_number(stock.get(id), 0.0, 0.0, CAPACITY - load_count()))
			if count > 0:
				backpack[id] = count
	tasks = stored["tasks"].duplicate() if stored.get("tasks") is Dictionary else {}
	var saved_notes: Variant = stored.get("notes")
	notes = saved_notes.duplicate(true) if saved_notes is Dictionary else {}


func _number(value: Variant, fallback: float, low: float, high: float) -> float:
	if (value is int or value is float) and is_finite(float(value)):
		return clampf(float(value), low, high)
	return fallback


func snapshot() -> Dictionary:
	return {"student_trait": student_trait, "equipment": equipment.duplicate(), "shops": shops.duplicate(), "minutes": minutes, "balance": balance, "hunger": hunger, "thirst": thirst,
		"backpack": backpack.duplicate(), "tasks": tasks.duplicate(), "notes": notes.duplicate(true)}


func advance(elapsed: float) -> void:
	if not is_finite(elapsed) or elapsed <= 0:
		return
	var week := floori(minutes / WEEK)
	minutes += elapsed
	balance += ALLOWANCE * (floori(minutes / WEEK) - week)
	hunger = minf(100.0, hunger + elapsed / 15.0)
	thirst = minf(100.0, thirst + elapsed / 12.0)


func load_count() -> int:
	var count := 0
	for amount in backpack.values():
		count += int(amount)
	return count


func buy(vendor: String, item: String) -> String:
	if not VENDORS.has(vendor) or not VENDORS[vendor][2].has(item):
		return "Ese producto no está disponible aquí."
	var price: int = ITEMS[item][1]
	if balance < price:
		return "Te faltan %d créditos." % (price - balance)
	if load_count() >= CAPACITY:
		return "Tu mochila está llena."
	if GEAR.has(item) and (equipment.has(item) or backpack.has(item)):
		return "Ya tienes ese objeto."
	shops[vendor] = true
	balance -= price
	backpack[item] = int(backpack.get(item, 0)) + 1
	return "%s guardado en la mochila." % ITEMS[item][0]


func consume(item: String) -> String:
	var count := int(backpack.get(item, 0))
	if count <= 0 or not ITEMS.has(item):
		return "Ese producto ya no está en tu mochila."
	if count == 1:
		backpack.erase(item)
	else:
		backpack[item] = count - 1
	if GEAR.has(item):
		equipment[item] = true
		return "%s en uso." % ITEMS[item][0]
	if item == "leche" and student_trait == "Intolerancia a la lactosa":
		hunger = minf(100.0, hunger + 8)
		return "El personaje tiene malestar. En el kiosco hay leche sin lactosa."
	hunger = maxf(0.0, hunger - float(ITEMS[item][2]))
	thirst = maxf(0.0, thirst - float(ITEMS[item][3]))
	return "%s · hambre %d%% · sed %d%%." % [ITEMS[item][0], roundi(hunger), roundi(thirst)]


func needs_glasses() -> bool:
	return student_trait == "Miopía" and not equipment.has("lentes")


func status() -> String:
	return "%d créditos · Hambre %d%% · Sed %d%%" % [balance, roundi(hunger), roundi(thirst)]
