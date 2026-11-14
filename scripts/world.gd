extends Node3D

signal mission_updated(collected: int, total: int)

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const PICKUP_SCENE: PackedScene = preload("res://scenes/pickup.tscn")
const CITY_RADIUS := 6
const BLOCK_SIZE := 34.0
const ROAD_WIDTH := 10.0
const WORLD_EXTENT := 450.0
const TOTAL_CORES := 8

var collected_cores := 0
var _environment: Environment
var _sky_material: ProceduralSkyMaterial
var _sun: DirectionalLight3D
var _is_night := false
var _materials: Dictionary = {}

func _ready() -> void:
    randomize()
    _create_materials()
    _make_environment()
    _make_ground_and_roads()
    _make_city()
    _make_street_lights()
    _make_parked_cars()
    _make_pickups()

    var player := PLAYER_SCENE.instantiate() as CharacterBody3D
    player.name = "Player"
    player.position = Vector3(0, 0.2, 13.0)
    add_child(player)
    mission_updated.emit(collected_cores, TOTAL_CORES)

func _process(delta: float) -> void:
    if is_instance_valid(_sun):
        _sun.rotation_degrees.y += delta * 0.6

func _create_materials() -> void:
    var ground_material := _mat(Color.WHITE, 0.98)
    _set_surface_detail(ground_material, "grass_albedo.png", "grass_normal.png", 0.075, 0.22)
    _materials["ground"] = ground_material
    var asphalt_material := _mat(Color.WHITE, 0.96)
    _set_surface_detail(asphalt_material, "asphalt_albedo.png", "asphalt_normal.png", 0.38, 0.24)
    _materials["asphalt"] = asphalt_material
    _materials["line_yellow"] = _mat(Color(0.95, 0.72, 0.17), 0.65)
    _materials["line_white"] = _mat(Color(0.78, 0.82, 0.82), 0.72)
    var sidewalk_material := _mat(Color.WHITE, 0.9)
    _set_surface_detail(sidewalk_material, "sidewalk_albedo.png", "sidewalk_normal.png", 0.24, 0.20)
    _materials["sidewalk"] = sidewalk_material
    _materials["curb"] = _mat(Color(0.58, 0.59, 0.56), 0.9)
    _materials["window"] = _mat(Color(0.055, 0.13, 0.19), 0.22)
    _materials["window_lit"] = _emission_mat(Color(0.95, 0.70, 0.34), Color(0.9, 0.43, 0.12), 0.32)
    _materials["roof"] = _mat(Color(0.12, 0.14, 0.16), 0.82)
    _materials["tree_trunk"] = _mat(Color(0.22, 0.11, 0.055), 0.95)
    _materials["tree_leaf"] = _mat(Color(0.09, 0.28, 0.13), 0.95)
    _materials["lamp"] = _emission_mat(Color(1.0, 0.83, 0.48), Color(1.0, 0.66, 0.22), 1.4)
    _materials["car_glass"] = _mat(Color(0.055, 0.12, 0.16), 0.18)
    _materials["car_tire"] = _mat(Color(0.018, 0.02, 0.023), 0.98)
    _materials["car_metal"] = _mat(Color(0.52, 0.56, 0.59), 0.38)

func _mat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material

func _set_surface_detail(material: StandardMaterial3D, albedo_file: String, normal_file: String, repeat_scale: float, normal_strength: float) -> void:
    material.albedo_texture = load("res://assets/" + albedo_file) as Texture2D
    material.uv1_triplanar = true
    material.uv1_scale = Vector3(repeat_scale, repeat_scale, repeat_scale)
    material.normal_enabled = true
    material.normal_texture = load("res://assets/" + normal_file) as Texture2D
    material.normal_scale = normal_strength

func _emission_mat(color: Color, emission: Color, energy: float) -> StandardMaterial3D:
    var material := _mat(color, 0.35, 0.15)
    material.emission_enabled = true
    material.emission = emission
    material.emission_energy_multiplier = energy
    return material

func _make_environment() -> void:
    var world_environment := WorldEnvironment.new()
    _environment = Environment.new()
    _environment.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    _sky_material = ProceduralSkyMaterial.new()
    _sky_material.sky_top_color = Color(0.12, 0.31, 0.53)
    _sky_material.sky_horizon_color = Color(0.63, 0.75, 0.86)
    _sky_material.ground_bottom_color = Color(0.12, 0.16, 0.18)
    _sky_material.ground_horizon_color = Color(0.49, 0.57, 0.62)
    sky.sky_material = _sky_material
    _environment.sky = sky
    _environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    _environment.ambient_light_color = Color(0.63, 0.70, 0.78)
    _environment.ambient_light_energy = 0.72
    _environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    _environment.fog_enabled = true
    _environment.fog_light_color = Color(0.62, 0.72, 0.80)
    _environment.fog_density = 0.0016
    world_environment.environment = _environment
    add_child(world_environment)

    _sun = DirectionalLight3D.new()
    _sun.rotation_degrees = Vector3(-48, -32, 0)
    _sun.light_color = Color(1.0, 0.91, 0.78)
    _sun.light_energy = 1.25
    _sun.shadow_enabled = true
    _sun.directional_shadow_max_distance = 110.0
    add_child(_sun)

func toggle_day_night() -> void:
    _is_night = not _is_night
    if _is_night:
        _sun.light_energy = 0.18
        _sun.light_color = Color(0.42, 0.53, 0.78)
        _environment.ambient_light_color = Color(0.14, 0.19, 0.30)
        _environment.ambient_light_energy = 0.42
        _sky_material.sky_top_color = Color(0.008, 0.018, 0.055)
        _sky_material.sky_horizon_color = Color(0.075, 0.12, 0.20)
        _environment.fog_light_color = Color(0.09, 0.14, 0.22)
    else:
        _sun.light_energy = 1.25
        _sun.light_color = Color(1.0, 0.91, 0.78)
        _environment.ambient_light_color = Color(0.63, 0.70, 0.78)
        _environment.ambient_light_energy = 0.72
        _sky_material.sky_top_color = Color(0.12, 0.31, 0.53)
        _sky_material.sky_horizon_color = Color(0.63, 0.75, 0.86)
        _environment.fog_light_color = Color(0.62, 0.72, 0.80)

func _make_ground_and_roads() -> void:
    var ground_body := StaticBody3D.new()
    ground_body.name = "GroundCollision"
    add_child(ground_body)
    _add_box_mesh(ground_body, Vector3(WORLD_EXTENT, 1.0, WORLD_EXTENT), Vector3(0, -0.5, 0), _get_material("ground"))
    var ground_shape := CollisionShape3D.new()
    var ground_box := BoxShape3D.new()
    ground_box.size = Vector3(WORLD_EXTENT, 1.0, WORLD_EXTENT)
    ground_shape.shape = ground_box
    ground_shape.position = Vector3(0, -0.5, 0)
    ground_body.add_child(ground_shape)

    var marking_transforms: Array[Transform3D] = []
    var edge_transforms: Array[Transform3D] = []
    for road_index in range(-CITY_RADIUS, CITY_RADIUS + 1):
        var road_pos := float(road_index) * BLOCK_SIZE
        _add_static_box(self, Vector3(ROAD_WIDTH, 0.16, WORLD_EXTENT), Vector3(road_pos, 0.08, 0), _get_material("asphalt"), "RoadSurface")
        _add_static_box(self, Vector3(WORLD_EXTENT, 0.16, ROAD_WIDTH), Vector3(0, 0.08, road_pos), _get_material("asphalt"), "RoadSurface")

        _add_static_box(self, Vector3(2.7, 0.22, WORLD_EXTENT), Vector3(road_pos - ROAD_WIDTH * 0.5 - 2.05, 0.11, 0), _get_material("sidewalk"), "Sidewalk")
        _add_static_box(self, Vector3(2.7, 0.22, WORLD_EXTENT), Vector3(road_pos + ROAD_WIDTH * 0.5 + 2.05, 0.11, 0), _get_material("sidewalk"), "Sidewalk")
        _add_static_box(self, Vector3(WORLD_EXTENT, 0.22, 2.7), Vector3(0, 0.11, road_pos - ROAD_WIDTH * 0.5 - 2.05), _get_material("sidewalk"), "Sidewalk")
        _add_static_box(self, Vector3(WORLD_EXTENT, 0.22, 2.7), Vector3(0, 0.11, road_pos + ROAD_WIDTH * 0.5 + 2.05), _get_material("sidewalk"), "Sidewalk")

        for along in range(-216, 217, 13):
            var z := float(along)
            marking_transforms.append(Transform3D(Basis.IDENTITY, Vector3(road_pos, 0.175, z)))
            marking_transforms.append(Transform3D(Basis(Vector3.UP, PI / 2.0), Vector3(z, 0.175, road_pos)))
            for edge in [-4.1, 4.1]:
                edge_transforms.append(Transform3D(Basis.IDENTITY, Vector3(road_pos + edge, 0.174, z)))
                edge_transforms.append(Transform3D(Basis(Vector3.UP, PI / 2.0), Vector3(z, 0.174, road_pos + edge)))

    var dash_mesh := BoxMesh.new()
    dash_mesh.size = Vector3(0.16, 0.025, 4.3)
    _add_multimesh(self, dash_mesh, _get_material("line_yellow"), marking_transforms)
    var edge_mesh := BoxMesh.new()
    edge_mesh.size = Vector3(0.11, 0.02, 6.8)
    _add_multimesh(self, edge_mesh, _get_material("line_white"), edge_transforms)

func _make_city() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 348291
    var palettes: Array[Color] = [
        Color(0.58, 0.62, 0.65), Color(0.70, 0.63, 0.54),
        Color(0.38, 0.48, 0.58), Color(0.76, 0.75, 0.68),
        Color(0.47, 0.54, 0.49), Color(0.62, 0.57, 0.53),
        Color(0.34, 0.39, 0.43)
    ]
    var tree_trunks: Array[Transform3D] = []
    var tree_crowns: Array[Transform3D] = []

    for x in range(-CITY_RADIUS, CITY_RADIUS):
        for z in range(-CITY_RADIUS, CITY_RADIUS):
            if abs(x) <= 1 and abs(z) <= 1:
                continue
            if rng.randf() < 0.07:
                continue
            var center_x := (float(x) + 0.5) * BLOCK_SIZE
            var center_z := (float(z) + 0.5) * BLOCK_SIZE
            var width := rng.randf_range(13.0, 17.0)
            var depth := rng.randf_range(13.0, 17.0)
            var floors := rng.randi_range(3, 10)
            if rng.randf() < 0.075:
                floors = rng.randi_range(12, 17)
            var height := float(floors) * rng.randf_range(2.9, 3.25)
            var facade := _mat(palettes[rng.randi_range(0, palettes.size() - 1)], 0.82, 0.04)
            _set_surface_detail(facade, "concrete_albedo.png", "concrete_normal.png", 0.28, 0.18)
            _create_building(Vector3(center_x, 0, center_z), width, depth, height, facade, rng)

            if rng.randf() < 0.72:
                var tree_side_x := -1.0 if rng.randf() < 0.5 else 1.0
                var tree_side_z := -1.0 if rng.randf() < 0.5 else 1.0
                var tree_pos := Vector3(center_x + tree_side_x * rng.randf_range(8.8, 10.5), 0, center_z + tree_side_z * rng.randf_range(8.8, 10.5))
                tree_trunks.append(Transform3D(Basis.IDENTITY, tree_pos + Vector3(0, 1.35, 0)))
                tree_crowns.append(Transform3D(Basis.IDENTITY, tree_pos + Vector3(0, 3.0, 0)))

    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.13
    trunk_mesh.bottom_radius = 0.20
    trunk_mesh.height = 2.7
    _add_multimesh(self, trunk_mesh, _get_material("tree_trunk"), tree_trunks)
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 1.35
    crown_mesh.height = 2.55
    _add_multimesh(self, crown_mesh, _get_material("tree_leaf"), tree_crowns)

func _create_building(origin: Vector3, width: float, depth: float, height: float, facade: Material, rng: RandomNumberGenerator) -> void:
    var building := StaticBody3D.new()
    building.position = origin
    building.name = "CityBuilding"
    add_child(building)

    _add_box_mesh(building, Vector3(width, height, depth), Vector3(0, height * 0.5, 0), facade)
    _add_box_mesh(building, Vector3(width + 0.35, 0.28, depth + 0.35), Vector3(0, height + 0.14, 0), _get_material("roof"))
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(width, height, depth)
    collision.shape = shape
    collision.position = Vector3(0, height * 0.5, 0)
    building.add_child(collision)

    var glass_mesh := BoxMesh.new()
    glass_mesh.size = Vector3(1.25, 1.42, 0.07)
    var windows: Array[Transform3D] = []
    var rows := maxi(1, int(height / 3.15))
    var columns := 3
    for floor_index in range(rows):
        var y := 1.2 + float(floor_index) * 3.05
        for col in range(columns):
            var x := (float(col) - 1.0) * (width / 3.5)
            windows.append(Transform3D(Basis.IDENTITY, Vector3(x, y, depth * 0.5 + 0.05)))
            windows.append(Transform3D(Basis.IDENTITY, Vector3(x, y, -depth * 0.5 - 0.05)))
            var side_z := (float(col) - 1.0) * (depth / 3.5)
            windows.append(Transform3D(Basis(Vector3.UP, PI / 2.0), Vector3(width * 0.5 + 0.05, y, side_z)))
            windows.append(Transform3D(Basis(Vector3.UP, PI / 2.0), Vector3(-width * 0.5 - 0.05, y, side_z)))
    _add_multimesh(building, glass_mesh, _get_material("window"), windows)

    if rng.randf() < 0.42:
        _add_box_mesh(building, Vector3(width * 0.34, 0.55, 0.18), Vector3(0, 1.35, depth * 0.5 + 0.12), _get_material("window_lit"))
    if rng.randf() < 0.22:
        _add_box_mesh(building, Vector3(1.2, rng.randf_range(1.5, 3.0), 1.2), Vector3(rng.randf_range(-2.0, 2.0), height + 0.9, rng.randf_range(-2.0, 2.0)), _get_material("roof"))

func _make_street_lights() -> void:
    var pole_transforms: Array[Transform3D] = []
    var lamp_transforms: Array[Transform3D] = []
    for road_index in range(-CITY_RADIUS + 1, CITY_RADIUS, 2):
        var road_pos := float(road_index) * BLOCK_SIZE
        for along in range(-170, 171, 85):
            var p := float(along)
            for side in [-1.0, 1.0]:
                var base_x := road_pos + side * 6.8
                pole_transforms.append(Transform3D(Basis.IDENTITY, Vector3(base_x, 3.22, p)))
                lamp_transforms.append(Transform3D(Basis.IDENTITY, Vector3(base_x, 6.17, p)))
                var base_z := road_pos + side * 6.8
                pole_transforms.append(Transform3D(Basis.IDENTITY, Vector3(p, 3.22, base_z)))
                lamp_transforms.append(Transform3D(Basis.IDENTITY, Vector3(p, 6.17, base_z)))

    var pole_mesh := CylinderMesh.new()
    pole_mesh.top_radius = 0.075
    pole_mesh.bottom_radius = 0.12
    pole_mesh.height = 6.0
    _add_multimesh(self, pole_mesh, _get_material("car_metal"), pole_transforms)
    var lamp_mesh := SphereMesh.new()
    lamp_mesh.radius = 0.22
    lamp_mesh.height = 0.44
    _add_multimesh(self, lamp_mesh, _get_material("lamp"), lamp_transforms)

func _make_parked_cars() -> void:
    var colors: Array[Color] = [Color(0.62, 0.12, 0.10), Color(0.10, 0.24, 0.55), Color(0.68, 0.70, 0.68), Color(0.09, 0.10, 0.12), Color(0.68, 0.54, 0.18)]
    var car_index := 0
    for road_index in [-4, -2, 2, 4]:
        var lane_x := float(road_index) * BLOCK_SIZE + (3.25 if road_index % 2 == 0 else -3.25)
        for along in [-135.0, -45.0, 45.0, 135.0]:
            if car_index >= 14:
                return
            _create_parked_car(Vector3(lane_x, 0, along), PI / 2.0, colors[car_index % colors.size()])
            car_index += 1

func _create_parked_car(origin: Vector3, yaw: float, color: Color) -> void:
    var car := StaticBody3D.new()
    car.position = origin + Vector3(0, 0.13, 0)
    car.rotation.y = yaw
    car.name = "ParkedCar"
    add_child(car)

    var body_material := _mat(color, 0.34, 0.28)
    var visual := Node3D.new()
    car.add_child(visual)
    _add_box_mesh(visual, Vector3(4.0, 0.78, 1.82), Vector3(0, 0.68, 0), body_material)
    _add_box_mesh(visual, Vector3(2.1, 0.72, 1.56), Vector3(-0.05, 1.34, 0), _get_material("car_glass"))
    _add_box_mesh(visual, Vector3(0.12, 0.12, 1.88), Vector3(1.75, 0.56, 0), _get_material("car_metal"))
    _add_box_mesh(visual, Vector3(0.12, 0.12, 1.88), Vector3(-1.75, 0.56, 0), _get_material("car_metal"))

    var wheel_mesh := CylinderMesh.new()
    wheel_mesh.top_radius = 0.39
    wheel_mesh.bottom_radius = 0.39
    wheel_mesh.height = 0.24
    for x in [-1.25, 1.25]:
        for z in [-0.91, 0.91]:
            var wheel := MeshInstance3D.new()
            wheel.mesh = wheel_mesh
            wheel.rotation.x = PI / 2.0
            wheel.position = Vector3(x, 0.42, z)
            wheel.material_override = _get_material("car_tire")
            visual.add_child(wheel)

    var shape_node := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(4.25, 1.65, 2.05)
    shape_node.shape = shape
    shape_node.position = Vector3(0, 0.86, 0)
    car.add_child(shape_node)

func _make_pickups() -> void:
    var locations: Array[Vector3] = [
        Vector3(9, 1.25, 13), Vector3(-9, 1.25, 13),
        Vector3(9, 1.25, -13), Vector3(-9, 1.25, -13),
        Vector3(45, 1.25, 45), Vector3(-45, 1.25, 45),
        Vector3(45, 1.25, -45), Vector3(-45, 1.25, -45)
    ]
    for location in locations:
        var pickup := PICKUP_SCENE.instantiate() as Area3D
        pickup.position = location
        pickup.connect("collected", _on_core_collected)
        add_child(pickup)

func _on_core_collected() -> void:
    collected_cores = mini(collected_cores + 1, TOTAL_CORES)
    mission_updated.emit(collected_cores, TOTAL_CORES)

func _get_material(key: String) -> Material:
    return _materials[key] as Material

func _add_static_box(parent: Node3D, size: Vector3, box_position: Vector3, material: Material, body_name: String) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = body_name
    body.position = box_position
    parent.add_child(body)
    var mesh := BoxMesh.new()
    mesh.size = size
    var visual := MeshInstance3D.new()
    visual.mesh = mesh
    visual.material_override = material
    body.add_child(visual)
    var collision := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    collision.shape = box
    body.add_child(collision)
    return body

func _add_box_mesh(parent: Node3D, size: Vector3, box_position: Vector3, material: Material) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.position = box_position
    instance.material_override = material
    parent.add_child(instance)
    return instance

func _add_multimesh(parent: Node3D, mesh: Mesh, material: Material, transforms: Array[Transform3D]) -> void:
    if transforms.is_empty():
        return
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.mesh = mesh
    multimesh.instance_count = transforms.size()
    for index in range(transforms.size()):
        multimesh.set_instance_transform(index, transforms[index])
    var instance := MultiMeshInstance3D.new()
    instance.multimesh = multimesh
    instance.material_override = material
    parent.add_child(instance)
