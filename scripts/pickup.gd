extends Area3D

signal collected

@onready var visual: Node3D = $CoreVisual
var _time := 0.0
var _base_y := 0.0

func _ready() -> void:
    _base_y = position.y
    body_entered.connect(_on_body_entered)
    var orb_material := StandardMaterial3D.new()
    orb_material.albedo_color = Color(0.12, 0.78, 0.95)
    orb_material.emission_enabled = true
    orb_material.emission = Color(0.05, 0.62, 0.95)
    orb_material.emission_energy_multiplier = 1.7
    orb_material.metallic = 0.35
    orb_material.roughness = 0.18
    $CoreVisual/Orb.material_override = orb_material

    var ring_material := StandardMaterial3D.new()
    ring_material.albedo_color = Color(0.35, 0.92, 1.0)
    ring_material.emission_enabled = true
    ring_material.emission = Color(0.08, 0.65, 1.0)
    ring_material.emission_energy_multiplier = 1.2
    ring_material.metallic = 0.4
    ring_material.roughness = 0.25
    $CoreVisual/Ring.material_override = ring_material

func _process(delta: float) -> void:
    _time += delta
    visual.rotation.y += delta * 1.15
    visual.position.y = sin(_time * 2.2) * 0.18

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("player"):
        collected.emit()
        queue_free()
