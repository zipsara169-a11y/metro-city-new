extends CharacterBody3D

signal speed_changed(speed_kmh: float)

@export var walk_speed: float = 5.8
@export var sprint_speed: float = 9.2
@export var acceleration: float = 20.0
@export var gravity: float = 22.0
@export var jump_velocity: float = 7.2
@export var look_sensitivity: float = 0.0042

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual_root: Node3D = $VisualRoot

var touch_move := Vector2.ZERO
var sprinting := false
var jump_requested := false
var _animation_clock := 0.0
var _speed_signal_timer := 0.0
var _left_arm: Node3D
var _right_arm: Node3D
var _left_leg: Node3D
var _right_leg: Node3D

func _ready() -> void:
    add_to_group("player")
    _build_character()
    if OS.has_feature("mobile"):
        camera_pivot.rotation.x = -0.12

func _build_character() -> void:
    var skin := _material(Color(0.72, 0.48, 0.32), 0.72)
    var jacket := _material(Color(0.055, 0.16, 0.28), 0.68)
    var trousers := _material(Color(0.075, 0.11, 0.17), 0.82)
    var shoes := _material(Color(0.025, 0.03, 0.04), 0.88)
    var hair := _material(Color(0.055, 0.035, 0.025), 0.9)
    var eye_mat := _material(Color(0.035, 0.025, 0.02), 0.45)

    _add_mesh(visual_root, _capsule(0.34, 0.82), Vector3(0, 1.18, 0), jacket)
    _add_mesh(visual_root, _sphere(0.22, 0.44), Vector3(0, 1.78, 0), skin)
    _add_mesh(visual_root, _sphere(0.225, 0.28), Vector3(0, 1.91, 0.015), hair)
    _add_mesh(visual_root, _sphere(0.035, 0.07), Vector3(-0.085, 1.81, -0.19), eye_mat)
    _add_mesh(visual_root, _sphere(0.035, 0.07), Vector3(0.085, 1.81, -0.19), eye_mat)

    _left_arm = _make_limb(Vector3(-0.40, 1.42, 0), 0.125, 0.66, skin, visual_root)
    _right_arm = _make_limb(Vector3(0.40, 1.42, 0), 0.125, 0.66, skin, visual_root)
    _left_leg = _make_limb(Vector3(-0.17, 0.76, 0), 0.15, 0.76, trousers, visual_root)
    _right_leg = _make_limb(Vector3(0.17, 0.76, 0), 0.15, 0.76, trousers, visual_root)

    _add_mesh(_left_arm, _box_mesh(Vector3(0.29, 0.15, 0.42)), Vector3(0, -0.37, -0.07), shoes)
    _add_mesh(_right_arm, _box_mesh(Vector3(0.29, 0.15, 0.42)), Vector3(0, -0.37, -0.07), shoes)
    _add_mesh(_left_leg, _box_mesh(Vector3(0.32, 0.16, 0.44)), Vector3(0, -0.43, -0.09), shoes)
    _add_mesh(_right_leg, _box_mesh(Vector3(0.32, 0.16, 0.44)), Vector3(0, -0.43, -0.09), shoes)

func _material(color: Color, roughness: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material

func _capsule(radius: float, height: float) -> CapsuleMesh:
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    return mesh

func _sphere(radius: float, height: float) -> SphereMesh:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = height
    return mesh

func _box_mesh(size: Vector3) -> BoxMesh:
    var mesh := BoxMesh.new()
    mesh.size = size
    return mesh

func _add_mesh(parent: Node3D, mesh: Mesh, mesh_position: Vector3, material: Material) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.position = mesh_position
    instance.material_override = material
    parent.add_child(instance)
    return instance

func _make_limb(origin: Vector3, radius: float, height: float, material: Material, parent: Node3D) -> Node3D:
    var pivot := Node3D.new()
    pivot.position = origin
    parent.add_child(pivot)
    _add_mesh(pivot, _capsule(radius, height), Vector3(0, -height * 0.35, 0), material)
    return pivot

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        apply_camera_drag(event.relative)
    elif event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event.is_action_pressed("jump"):
        request_jump()

func apply_camera_drag(relative: Vector2) -> void:
    camera_pivot.rotate_y(-relative.x * look_sensitivity)
    camera_pivot.rotation.x = clamp(camera_pivot.rotation.x - relative.y * look_sensitivity, -0.78, 0.34)

func _physics_process(delta: float) -> void:
    var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var input_vector := keyboard if keyboard.length() > 0.08 else touch_move
    var camera_basis := camera_pivot.global_transform.basis
    var forward := -camera_basis.z
    var right := camera_basis.x
    var direction := (right * input_vector.x + forward * -input_vector.y)
    direction.y = 0.0
    direction = direction.normalized()

    var target_speed := sprint_speed if (sprinting or Input.is_action_pressed("sprint")) else walk_speed
    var target_velocity := direction * target_speed
    velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        if velocity.y < 0.0:
            velocity.y = -0.15
        if jump_requested:
            velocity.y = jump_velocity
    jump_requested = false

    if direction.length() > 0.08:
        var target_yaw := atan2(-direction.x, -direction.z)
        visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_yaw, 11.0 * delta)
        _animation_clock += delta * (13.0 if target_speed == sprint_speed else 9.0)
        _left_arm.rotation.x = sin(_animation_clock) * 0.58
        _right_arm.rotation.x = -sin(_animation_clock) * 0.58
        _left_leg.rotation.x = -sin(_animation_clock) * 0.62
        _right_leg.rotation.x = sin(_animation_clock) * 0.62
    else:
        _left_arm.rotation.x = lerp_angle(_left_arm.rotation.x, 0.0, 10.0 * delta)
        _right_arm.rotation.x = lerp_angle(_right_arm.rotation.x, 0.0, 10.0 * delta)
        _left_leg.rotation.x = lerp_angle(_left_leg.rotation.x, 0.0, 10.0 * delta)
        _right_leg.rotation.x = lerp_angle(_right_leg.rotation.x, 0.0, 10.0 * delta)

    move_and_slide()
    _speed_signal_timer += delta
    if _speed_signal_timer >= 0.15:
        _speed_signal_timer = 0.0
        speed_changed.emit(Vector2(velocity.x, velocity.z).length() * 3.6)

func set_touch_move(value: Vector2) -> void:
    touch_move = value.limit_length(1.0)

func set_sprinting(value: bool) -> void:
    sprinting = value

func request_jump() -> void:
    jump_requested = true
