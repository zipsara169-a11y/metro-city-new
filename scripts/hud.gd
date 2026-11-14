extends CanvasLayer

var player: CharacterBody3D
var world: Node3D
var joystick_pad: Panel
var joystick_thumb: Panel
var speed_label: Label
var mission_label: Label
var status_label: Label
var joystick_active := false
var move_vector := Vector2.ZERO
var look_touch_id := -1

func _ready() -> void:
    await get_tree().process_frame
    world = get_parent() as Node3D
    player = world.get_node_or_null("Player") as CharacterBody3D
    _build_hud()
    if is_instance_valid(player):
        player.connect("speed_changed", _on_speed_changed)
    if world != null and world.has_signal("mission_updated"):
        world.connect("mission_updated", _on_mission_updated)

func _build_hud() -> void:
    var root := Control.new()
    root.name = "HUDRoot"
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_PASS
    add_child(root)

    var header := _make_panel(root, Vector2(20, 18), Vector2(348, 112), Color(0.025, 0.045, 0.07, 0.82), 18)
    var title := _make_label(header, "METRO CITY", Vector2(18, 12), 22, Color(0.92, 0.97, 1.0))
    title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
    _make_label(header, "OPEN WORLD  •  EXPLORATION", Vector2(20, 43), 11, Color(0.54, 0.76, 0.88))
    mission_label = _make_label(header, "ENERGY CORES   0 / 8", Vector2(20, 72), 15, Color(0.30, 0.88, 1.0))

    var stats := _make_panel(root, Vector2(-198, 18), Vector2(178, 66), Color(0.025, 0.045, 0.07, 0.78), 16)
    stats.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
    speed_label = _make_label(stats, "0 KM/H", Vector2(18, 10), 23, Color(1.0, 1.0, 1.0))
    _make_label(stats, "CURRENT SPEED", Vector2(19, 39), 10, Color(0.59, 0.72, 0.82))

    var time_button := _make_button(root, "DAY / NIGHT", Vector2(-160, 98), Vector2(140, 48), Color(0.05, 0.14, 0.22, 0.88))
    time_button.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
    time_button.pressed.connect(_toggle_time)

    status_label = _make_label(root, "DRAG RIGHT SIDE TO LOOK", Vector2(0, 0), 12, Color(0.87, 0.94, 1.0))
    status_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    status_label.position = Vector2(-104, -34)

    joystick_pad = Panel.new()
    joystick_pad.name = "MoveJoystick"
    joystick_pad.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    joystick_pad.position = Vector2(28, -190)
    joystick_pad.size = Vector2(162, 162)
    joystick_pad.mouse_filter = Control.MOUSE_FILTER_STOP
    _apply_panel_style(joystick_pad, Color(0.035, 0.075, 0.11, 0.48), 81, Color(0.55, 0.78, 0.92, 0.32), 2)
    root.add_child(joystick_pad)
    joystick_pad.gui_input.connect(_on_joystick_input)

    joystick_thumb = Panel.new()
    joystick_thumb.position = Vector2(53, 53)
    joystick_thumb.size = Vector2(56, 56)
    joystick_thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _apply_panel_style(joystick_thumb, Color(0.27, 0.63, 0.79, 0.72), 28, Color(0.82, 0.95, 1.0, 0.7), 2)
    joystick_pad.add_child(joystick_thumb)

    var joystick_hint := _make_label(root, "MOVE", Vector2(78, -34), 11, Color(0.87, 0.95, 1.0))
    joystick_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT, true)

    var run_button := _make_button(root, "RUN", Vector2(-142, -108), Vector2(112, 70), Color(0.05, 0.18, 0.27, 0.9))
    run_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT, true)
    run_button.button_down.connect(_set_sprint.bind(true))
    run_button.button_up.connect(_set_sprint.bind(false))

    var jump_button := _make_button(root, "JUMP", Vector2(-142, -192), Vector2(112, 70), Color(0.05, 0.28, 0.34, 0.92))
    jump_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT, true)
    jump_button.pressed.connect(_jump)

func _make_panel(parent: Control, pos: Vector2, panel_size: Vector2, color: Color, radius: int) -> Panel:
    var panel := Panel.new()
    panel.position = pos
    panel.size = panel_size
    _apply_panel_style(panel, color, radius, Color(0.45, 0.70, 0.84, 0.18), 1)
    parent.add_child(panel)
    return panel

func _apply_panel_style(panel: Panel, color: Color, radius: int, border_color: Color, border_width: int) -> void:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.border_color = border_color
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    panel.add_theme_stylebox_override("panel", style)

func _make_label(parent: Control, text_value: String, pos: Vector2, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = text_value
    label.position = pos
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    parent.add_child(label)
    return label

func _make_button(parent: Control, text_value: String, pos: Vector2, button_size: Vector2, color: Color) -> Button:
    var button := Button.new()
    button.text = text_value
    button.position = pos
    button.size = button_size
    button.add_theme_font_size_override("font_size", 17)
    button.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
    button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
    var normal := StyleBoxFlat.new()
    normal.bg_color = color
    normal.corner_radius_top_left = 15
    normal.corner_radius_top_right = 15
    normal.corner_radius_bottom_left = 15
    normal.corner_radius_bottom_right = 15
    normal.border_width_left = 1
    normal.border_width_top = 1
    normal.border_width_right = 1
    normal.border_width_bottom = 1
    normal.border_color = Color(0.58, 0.82, 0.95, 0.42)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = color.lightened(0.16)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = color.darkened(0.18)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    parent.add_child(button)
    return button

func _input(event: InputEvent) -> void:
    if not is_instance_valid(player):
        return
    var viewport_size := get_viewport().get_visible_rect().size
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x > viewport_size.x * 0.43 and event.position.y < viewport_size.y - 255:
                look_touch_id = event.index
        elif event.index == look_touch_id:
            look_touch_id = -1
    elif event is InputEventScreenDrag and event.index == look_touch_id:
        player.call("apply_camera_drag", event.relative)

func _on_joystick_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            joystick_active = true
            _update_joystick(event.position)
        else:
            _reset_joystick()
    elif event is InputEventScreenDrag and joystick_active:
        _update_joystick(event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            joystick_active = true
            _update_joystick(event.position)
        else:
            _reset_joystick()
    elif event is InputEventMouseMotion and joystick_active:
        _update_joystick(event.position)

func _update_joystick(screen_position: Vector2) -> void:
    var local_position: Vector2 = joystick_pad.get_global_transform_with_canvas().affine_inverse() * screen_position
    var offset := (local_position - joystick_pad.size * 0.5).limit_length(52.0)
    joystick_thumb.position = joystick_pad.size * 0.5 + offset - joystick_thumb.size * 0.5
    move_vector = Vector2(offset.x / 52.0, -offset.y / 52.0).limit_length(1.0)
    if is_instance_valid(player):
        player.call("set_touch_move", move_vector)

func _reset_joystick() -> void:
    joystick_active = false
    move_vector = Vector2.ZERO
    joystick_thumb.position = joystick_pad.size * 0.5 - joystick_thumb.size * 0.5
    if is_instance_valid(player):
        player.call("set_touch_move", Vector2.ZERO)

func _set_sprint(value: bool) -> void:
    if is_instance_valid(player):
        player.call("set_sprinting", value)

func _jump() -> void:
    if is_instance_valid(player):
        player.call("request_jump")

func _toggle_time() -> void:
    if world != null and world.has_method("toggle_day_night"):
        world.call("toggle_day_night")

func _on_speed_changed(speed_kmh: float) -> void:
    if is_instance_valid(speed_label):
        speed_label.text = "%d KM/H" % roundi(speed_kmh)

func _on_mission_updated(collected: int, total: int) -> void:
    if is_instance_valid(mission_label):
        mission_label.text = "ENERGY CORES   %d / %d" % [collected, total]
        if collected >= total:
            mission_label.text = "MISSION COMPLETE  ✓"
