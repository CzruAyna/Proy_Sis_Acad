extends SceneTree

const Icon = preload("res://scripts/pixel_app_icon.gd")


func _initialize() -> void:
	var target := "res://assets/branding/sis_inf_pixel"
	var result := Icon.image_at(256).save_png(target + ".png")
	if result != OK:
		quit(1)
		return
	var sizes := [16, 24, 32, 48, 64, 128, 256]
	var blobs: Array[PackedByteArray] = []
	for side in sizes:
		blobs.append(Icon.image_at(side).save_png_to_buffer())
	var ico := FileAccess.open(target + ".ico", FileAccess.WRITE)
	if ico == null:
		quit(1)
		return
	ico.store_16(0)
	ico.store_16(1)
	ico.store_16(sizes.size())
	var offset := 6 + 16 * sizes.size()
	for index in range(sizes.size()):
		ico.store_8(sizes[index] % 256)
		ico.store_8(sizes[index] % 256)
		ico.store_8(0)
		ico.store_8(0)
		ico.store_16(1)
		ico.store_16(32)
		ico.store_32(blobs[index].size())
		ico.store_32(offset)
		offset += blobs[index].size()
	for blob in blobs:
		ico.store_buffer(blob)
	ico.close()
	print("PIXEL_ICON: PNG 256 + ICO ", sizes)
	quit(0)
