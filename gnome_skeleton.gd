class_name GnomeSkeleton extends Node3D

@export var gnome_data: Resource 

const SOCKET_MAP = {
	Gnome.GNOME_PIECE_TYPES.HEAD: "place-head",
	Gnome.GNOME_PIECE_TYPES.LEG: "place-leg",
	Gnome.GNOME_PIECE_TYPES.HAT: "place-hat",
	Gnome.GNOME_PIECE_TYPES.EYE: "place-eye",
	Gnome.GNOME_PIECE_TYPES.EAR: "place-ear",
	Gnome.GNOME_PIECE_TYPES.MOUTH: "place-mouth",
	Gnome.GNOME_PIECE_TYPES.NOSE: "place-nose",
	Gnome.GNOME_PIECE_TYPES.BODY: "place-body"
}

var appendage_map : Dictionary[String, Node3D] = {

}

func _ready() -> void:
	if !gnome_data:
		gnome_data = GnomeGenerator.generate_gnome()
	assemble_gnome()

func assemble_gnome():
	for child in get_children():
		child.queue_free()

	if not gnome_data or not gnome_data.skeleton_pieces.has(Gnome.GNOME_PIECE_TYPES.BODY):
		return
	
	#var body_scene = gnome_data.skeleton_pieces[Gnome.GNOME_PIECE_TYPES.BODY]
	#var body_instance = body_scene.instantiate()
	#add_child(body_instance)
	#appendage_map["body"] = body_instance
	# Apply colors to the body itself
	#_apply_palette_to_node(body_instance)
	
	#_process_node_sockets(body_instance)

	var place_body_node = Node3D.new()
	place_body_node.name = "place-body"
	add_child(place_body_node)

	_process_node_sockets(self)

func _process_node_sockets(current_node: Node):
	for child in current_node.get_children():
		if child is Node3D and child.name.begins_with("place-"):
			_attach_to_socket(child)
		
		_process_node_sockets(child)

func _attach_to_socket(socket: Node3D):
	var regex = RegEx.new()
	regex.compile("_\\d+$") 
	var clean_name = regex.sub(socket.name, "", false)
	
	for piece_type in SOCKET_MAP:
		var socket_id = SOCKET_MAP[piece_type]
		
		if clean_name.contains(socket_id):
			var scene = gnome_data.skeleton_pieces.get(piece_type)
			if scene:
				var instance = scene.instantiate()
				socket.add_child(instance)
				appendage_map[clean_name.replace("place-", "")] = instance
				# 1. Apply Mirroring
				if clean_name.ends_with("_l"):
					instance.scale.x = -1.0
				
				# 2. Apply Palette (The New Step)
				_apply_palette_to_node(instance)
			return

## Scans the instance for meshes and matches material names to the color_map
func _apply_palette_to_node(root_node: Node):
	for child in root_node.get_children(true): # 'true' to include internal nodes if necessary
		if child is MeshInstance3D:
			print(child.name, " ", child.mesh.get_surface_count())
			for idx in range(child.mesh.get_surface_count()):
				var mat = child.mesh.surface_get_material(idx)
				var surface_path = "surface_%s/name" 
				var mat_name = child.mesh.get(surface_path % str(idx))
				if mat:
					# Check if the material name (or a part of it) exists in our map
					for color_key in gnome_data.color_map:
						if mat_name.contains(color_key):
							# Duplicate the material so we don't change the color for ALL gnomes!
							var new_mat = mat.duplicate()
							new_mat.set("shader_parameter/albedo_color", gnome_data.color_map[color_key])
							child.set_surface_override_material(idx, new_mat)
		# Recurse if the piece has nested children (like a sub-mesh)
		if child.get_child_count() > 0:
			_apply_palette_to_node(child)