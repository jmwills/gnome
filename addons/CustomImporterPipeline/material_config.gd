# material_config.gd
extends Resource
class_name MaterialConfig

# The fallback material used if no prefix match is found.
@export var default_material: ShaderMaterial = preload("res://shaders/toon_shader.tres")

# The dictionary that maps mesh name prefixes to specific materials.
@export var material_prefix_map: Dictionary = {
}