@tool
extends Node
class_name MainMenuBuilder

# ---------- Paths (editable in Inspector) ----------
@export_file("*.ttf", "*.otf") var font_path := "res://assets/fonts/ProggyVector-Regular.ttf"
@export_file("*.png", "*.jpg", "*.webp") var title_image_path := "res://assets/screens/uoc-main-title.png"

# ---------- Behavior ----------
@export var auto_build_on_ready: bool = true

# Title scaling (keeps aspect)
@export var title_max_width_ratio: float  = 0.90
@export var title_max_height_ratio: float = 0.33
@export var title_top_margin_px: int      = 0

# Menu sizing/placement
@export var menu_width: int  = 360
@export var menu_height: int = 240
@export var menu_center_y_ratio: float = 0.50  # 0=top, 0.5=middle, 1=bottom

# Button look
@export var button_texts: PackedStringArray = ["Play Game", "Editor", "Options", "Quit"]
@export var font_size: int = 42
@export var font_color: Color = Color(1.0, 0.23, 0.23)   # bright red
@export var outline_color: Color = Color(0, 0, 0, 0.95)
@export var outline_size: int = 4

# Debug (optional helper)
@export var debug_menu_backdrop: bool = false   # shows a translucent plate behind the menu

# Editor helpers
@export var rebuild_now: bool = false : set = _set_rebuild_now
@export var add_button_text: String = "New Button"
@export var add_button_now: bool = false : set = _set_add_button_now

func _ready() -> void:
	if Engine.is_editor_hint() and auto_build_on_ready:
		_build_or_refresh()
	elif not Engine.is_editor_hint():
		# Build at runtime too so the layout matches the real viewport
		_build_or_refresh()

func _set_rebuild_now(v: bool) -> void:
	if not Engine.is_editor_hint():
		rebuild_now = false
		return
	if v:
		_build_or_refresh()
	rebuild_now = false

func _set_add_button_now(v: bool) -> void:
	if not Engine.is_editor_hint():
		add_button_now = false
		return
	if v:
		var vbox := _get_or_make_vbox()
		if vbox:
			var btn := _make_button(add_button_text)
			_add_owned(vbox, btn)
			_theme_one_button(btn, _get_font())
			if not button_texts.has(add_button_text):
				button_texts.append(add_button_text)
	add_button_now = false

# ---------------------------------------------------
# Build / Refresh
# ---------------------------------------------------
func _build_or_refresh() -> void:
	_sanitize_exports()

	# GameRoot holder
	var game_root := get_node_or_null("GameRoot") as Node2D
	if game_root == null:
		game_root = Node2D.new()
		game_root.name = "GameRoot"
		_add_owned(self, game_root)
		var hint := Label.new()
		hint.text = "Mini single-player area (replace with your scene)"
		hint.modulate = Color(1,1,1,0.85)
		hint.position = Vector2(40, 40)
		_add_owned(game_root, hint)

	# CanvasLayer
	var menu_layer := get_node_or_null("MenuLayer") as CanvasLayer
	if menu_layer == null:
		menu_layer = CanvasLayer.new()
		menu_layer.name = "MenuLayer"
		menu_layer.layer = 10
		_add_owned(self, menu_layer)
	menu_layer.visible = true

	# UI root (fullscreen)
	var ui := menu_layer.get_node_or_null("UI") as Control
	if ui == null:
		ui = Control.new()
		ui.name = "UI"
		_add_owned(menu_layer, ui)
	ui.anchor_left = 0; ui.anchor_top = 0; ui.anchor_right = 1; ui.anchor_bottom = 1
	ui.offset_left = 0; ui.offset_top = 0; ui.offset_right = 0; ui.offset_bottom = 0
	ui.visible = true

	# Title image (single)
	var title_img := ui.get_node_or_null("TitleImage") as TextureRect
	if title_img == null:
		title_img = TextureRect.new()
		title_img.name = "TitleImage"
		_add_owned(ui, title_img)

	var win_size: Vector2 = _get_effective_window_size()
	ui.size = win_size

	# Load texture
	if ResourceLoader.exists(title_image_path):
		title_img.texture = load(title_image_path) as Texture2D
	else:
		title_img.texture = null

	title_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT

	# Reset layout fully
	title_img.anchor_left = 0; title_img.anchor_top = 0; title_img.anchor_right = 0; title_img.anchor_bottom = 0
	title_img.offset_left = 0; title_img.offset_top = 0; title_img.offset_right = 0; title_img.offset_bottom = 0
	title_img.pivot_offset = Vector2.ZERO

	# Compute size and absolute placement (top-center)
	var title_size: Vector2 = Vector2.ZERO
	if title_img.texture:
		var tex_sz: Vector2 = title_img.texture.get_size()
		var max_bounds: Vector2 = Vector2(win_size.x * title_max_width_ratio, win_size.y * title_max_height_ratio)
		title_size = _scale_to_fit(tex_sz, max_bounds)

	title_img.size = title_size
	title_img.global_position = Vector2((win_size.x - title_size.x) * 0.5, float(title_top_margin_px))
	title_img.z_index = -100

	# VBox menu
	var vbox := _get_or_make_vbox()
	vbox.anchor_left = 0; vbox.anchor_top = 0; vbox.anchor_right = 0; vbox.anchor_bottom = 0
	vbox.offset_left = 0; vbox.offset_top = 0; vbox.offset_right = 0; vbox.offset_bottom = 0
	vbox.pivot_offset = Vector2.ZERO
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	vbox.visible = true
	vbox.z_index = 100

	var cx: float = (win_size.x - float(menu_width)) * 0.5
	var cy: float = clampf(menu_center_y_ratio, 0.0, 1.0) * win_size.y - float(menu_height) * 0.5
	vbox.custom_minimum_size = Vector2(menu_width, menu_height)
	vbox.size = vbox.custom_minimum_size
	vbox.position = Vector2(int(cx), int(cy))

	# Optional debug backdrop behind menu
	var plate := vbox.get_node_or_null("DebugPlate") as ColorRect
	if debug_menu_backdrop:
		if plate == null:
			plate = ColorRect.new()
			plate.name = "DebugPlate"
			plate.color = Color(0,0,0,0.35)
			plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_add_owned(vbox, plate)
			vbox.move_child(plate, 0) # behind buttons
		plate.visible = true
		plate.size = vbox.size
		plate.position = Vector2.ZERO
	elif plate != null:
		plate.visible = false

	# Recreate buttons from list
	for c in vbox.get_children():
		if c is Button:
			vbox.remove_child(c); c.queue_free()

	var labels: PackedStringArray = button_texts
	if labels.size() == 0:
		labels = PackedStringArray(["Play Game","Editor","Options","Quit"])
	for label in labels:
		var btn := _make_button(label)
		_add_owned(vbox, btn)

	# Theme
	var the_font := _get_font()
	for child in vbox.get_children():
		if child is Button:
			_theme_one_button(child as Button, the_font)

	if Engine.is_editor_hint():
		notify_property_list_changed()
	else:
		# Helpful one-shot log at runtime
		print("MainMenuBuilder: win_size=", win_size, " menu at ", vbox.position, " size ", vbox.size)

# ---------------------------------------------------
# Creators / helpers
# ---------------------------------------------------
func _make_button(label: String) -> Button:
	var btn := Button.new()
	btn.name = label
	btn.text = label
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(280, 54)
	btn.pressed.connect(_on_menu_button_pressed.bind(label))
	return btn

func _theme_one_button(btn: Button, f: Font) -> void:
	btn.add_theme_font_override("font", f)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", font_color)
	btn.add_theme_color_override("font_hover_color", font_color.lightened(0.15))
	btn.add_theme_color_override("font_pressed_color", font_color.lightened(0.1))
	btn.add_theme_color_override("font_outline_color", outline_color)
	btn.add_theme_constant_override("font_outline_size", outline_size)
	btn.add_theme_constant_override("content_margin_left", 14)
	btn.add_theme_constant_override("content_margin_right", 14)
	btn.add_theme_constant_override("content_margin_top", 8)
	btn.add_theme_constant_override("content_margin_bottom", 8)

func _get_or_make_vbox() -> VBoxContainer:
	var menu_layer := get_node("MenuLayer") as CanvasLayer
	var ui := (menu_layer.get_node_or_null("UI") as Control)
	var vbox := ui.get_node_or_null("VBoxContainer") as VBoxContainer
	if vbox == null:
		vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		_add_owned(ui, vbox)
	return vbox

func _get_font() -> Font:
	var f: Font = ThemeDB.fallback_font
	if ResourceLoader.exists(font_path):
		f = load(font_path) as Font
	return f

# Ensure editor-created nodes get saved & appear in Scene panel
func _add_owned(parent: Node, child: Node) -> void:
	parent.add_child(child, true)
	if Engine.is_editor_hint():
		var root := get_tree().edited_scene_root
		if root:
			child.owner = root

# ---------------------------------------------------
# Button actions (stubs)
# ---------------------------------------------------
func _on_menu_button_pressed(which: String) -> void:
	match which:
		"Play Game":
			get_node("GameRoot").visible = true
			get_node("MenuLayer/UI").visible = false
		"Editor":
			_print_editor_hint("Open your in-game editor here.")
		"Options":
			_print_editor_hint("Open your options popup here.")
		"Quit":
			if Engine.is_editor_hint():
				_print_editor_hint("Quit suppressed in editor. Will quit in a running game.")
			else:
				get_tree().quit()

func _print_editor_hint(msg: String) -> void:
	if Engine.is_editor_hint(): push_warning(msg)
	else: print(msg)

func show_menu_again() -> void:
	var ui := get_node_or_null("MenuLayer/UI") as Control
	if ui: ui.visible = true

# ---------------------------------------------------
# Util
# ---------------------------------------------------
func _sanitize_exports() -> void:
	if title_max_width_ratio <= 0.0:  title_max_width_ratio = 0.90
	if title_max_height_ratio <= 0.0: title_max_height_ratio = 0.33
	if menu_width <= 0:               menu_width = 360
	if menu_height <= 0:              menu_height = 240
	menu_center_y_ratio = clampf(menu_center_y_ratio, 0.0, 1.0)

# Use real viewport size while playing; project size in editor (stable preview)
func _get_effective_window_size() -> Vector2:
	if Engine.is_editor_hint():
		return _get_project_window_size()
	else:
		return get_viewport().get_visible_rect().size

func _get_project_window_size() -> Vector2:
	var w: int = int(ProjectSettings.get_setting("display/window/size/viewport_width", 1920))
	var h: int = int(ProjectSettings.get_setting("display/window/size/viewport_height", 1080))
	return Vector2(w, h)

func _scale_to_fit(src: Vector2, bounds: Vector2) -> Vector2:
	if src.x <= 0.0 or src.y <= 0.0:
		return Vector2.ZERO
	var sx: float = bounds.x / src.x
	var sy: float = bounds.y / src.y
	var s: float = min(min(sx, sy), 1.0)  # never upscale in editor
	return src * s
