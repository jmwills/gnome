@tool
extends Node
class_name AppendageGenerator

@export_dir var source_folder : String
@export_dir var target_folder : String

@export var generate_resources := false:
	set(value):
		if value:
			generate_resources = false
			_generate()

# NEW BUTTON
@export var generate_test_appendages := false:
	set(value):
		if value:
			generate_test_appendages = false
			_generate_test_appendages()

@export var purge_unmatched_resources := false :
	set(value):
		_purge_unmatched_pieces()

func _generate():
	if source_folder.is_empty() or target_folder.is_empty():
		push_error("Source or target folder not set.")
		return
	
	var dir := DirAccess.open(source_folder)
	if dir == null:
		push_error("Cannot open source folder.")
		return
	
	DirAccess.make_dir_recursive_absolute(target_folder)

	dir.list_dir_begin()
	var folder_name = dir.get_next()

	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			folder_name = folder_name.to_lower()
			var socket_type = _get_socket_type_from_name(folder_name)
			if socket_type == null:
				push_warning("Folder '%s' does not match SocketType enum." % folder_name)
			else:
				_process_socket_folder(folder_name, socket_type)
		
		folder_name = dir.get_next()
	
	dir.list_dir_end()
	print("Appendage generation complete.")


# NEW FUNCTION
func _generate_test_appendages():
	if target_folder.is_empty():
		push_error("Target folder not set.")
		return

	DirAccess.make_dir_recursive_absolute(target_folder)

	var socket_keys = SocketInfo.SocketType.keys()
	if socket_keys.is_empty():
		push_error("No SocketTypes found.")
		return

	randomize()

	for i in 1000:
		var appendage := Appendage.new()

		# Pick random socket type
		var random_key = socket_keys[randi() % socket_keys.size()]
		appendage.socket_type = SocketInfo.SocketType[random_key]

		# Optional: leave scene null or assign a dummy one if needed
		appendage.scene = null

		var save_name = "test_appendage_%04d.tres" % i
		var save_path = target_folder.path_join(save_name)

		var err = ResourceSaver.save(appendage, save_path)
		if err != OK:
			push_error("Failed to save: %s" % save_path)

	print("Generated 1000 test appendages.")


func _process_socket_folder(folder_name: String, socket_type: int):
	print("Processing folder ", folder_name)
	var full_path = source_folder.path_join(folder_name)
	var subdir := DirAccess.open(full_path)
	if subdir == null:
		push_error("Cannot open subfolder: %s" % full_path)
		return
	
	subdir.list_dir_begin()
	var file_name = subdir.get_next()
	while file_name != "":
		if not subdir.current_is_dir() and file_name.get_extension() in ["tscn", "gltf", "glb"]:
			
			var scene_path = full_path.path_join(file_name)
			var scene := load(scene_path) as PackedScene
			
			if scene:
				var appendage := Appendage.new()
				appendage.scene = scene
				appendage.socket_type = socket_type
				
				var save_name = file_name.get_basename() + ".tres"
				var save_path = target_folder.path_join(save_name)

				var err = ResourceSaver.save(appendage, save_path)
				if err != OK:
					push_error("Failed to save: %s" % save_path)
				else:
					print("Created: %s" % save_path)

		file_name = subdir.get_next()
	
	subdir.list_dir_end()

func _purge_unmatched_pieces():
	var subdir := DirAccess.open(target_folder)
	if subdir == null:
		push_error("Cannot open subfolder: %s" % target_folder)
		return
	subdir.list_dir_begin()
	var file_name = subdir.get_next()
	while file_name != "":
		if not subdir.current_is_dir():
			print(file_name)
		file_name = subdir.get_next()

func _get_socket_type_from_name(name: String):
	for key in SocketInfo.SocketType.keys():
		if key == name.to_upper():
			return SocketInfo.SocketType[key]
	return null
