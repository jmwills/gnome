@tool
extends EditorScenePostImportPlugin

# =========================================================
# CONFIG
# =========================================================

# Only process imports inside this folder (including subfolders)
@export_dir var target_import_root : String = "res://models"

# Map folder → material
# Example:
# {
#   "res://models/terrain": "res://shaders/terrain/basic_grass.tres",
#   "res://models/water": "res://shaders/WaterShader.tres"
# }
@export var folder_to_material : Dictionary = {
	"res://gnome_parts/": "res://shaders/toon_shader.tres"
}

# Field remapping
# Example:
# {
#   "albedo_texture": "albedo_texture",
#   "albedo_color": "albedo_color",
# }
@export var field_remap : Dictionary = {
  #"albedo_texture": "albedo_texture",
  "albedo_color": "albedo_color",
}

# =========================================================

func _get_importer_name():
	return "folder_shader_importer"

func _get_visible_name():
	return "Folder Shader Importer"

# =========================================================


func _get_import_options(path: String) -> void:
	# save the file path to the import setting
	add_import_option("file_path", path)


func _pre_process(scene: Node) -> void:
	iterate(scene)#, load(material_path))

func _get_material_for_path(import_path: String) -> String:
	var best_match := ""
	var best_length := -1

	for folder_path in folder_to_material.keys():
		if import_path.begins_with(folder_path):
			if folder_path.length() > best_length:
				best_length = folder_path.length()
				best_match = folder_path

	if best_match == "":
		return ""

	return folder_to_material[best_match]


func iterate(node: Node) -> void:
	if node is ImporterMeshInstance3D:
		_apply_material(node.mesh, load(_get_material_for_path(get_option_value("file_path"))))

	for child in node.get_children():
		iterate(child)#, base_material)


func _apply_material(mesh: ImporterMesh, base_material: ShaderMaterial):
	for i in mesh.get_surface_count():
		var source_material = mesh.get_surface_material(i)
		print(source_material)
		if source_material == null:
			continue

		var new_material := base_material.duplicate()

		for old_field in field_remap.keys():
			var new_field = field_remap[old_field]

			var value = source_material.get(old_field)
			print(value)
			if value != null:
				new_material.set("shader_parameter/" + new_field, value)

		mesh.set_surface_material(i, new_material)