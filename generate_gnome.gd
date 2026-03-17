@tool
extends Node

## Naming
var _last_names = "Durst,Furst,Kurst,Trest,Melpy,Mergins,Happness,Broond,Ash,Lamp"
var _first_names = "Mee,Gee,Jee,Flee,Boo,Stoo,Fern,Broom,Floom,Thimble,Clem,Sadey,Femmy,Humble,Broogin,Dergin,Stren,Wee,Woh,Clew,Oil,Plen"
var first_names = []
var last_names = []

@export var gnome_pieces_path : String = "res://gnome_data/pieces/"
@export var socket_info_path : String = "res://gnome_data/sockets/"

var socket_to_pieces : Dictionary = {}

var socket_info : Dictionary[SocketInfo.SocketType, SocketInfo]

func _populate_name_lists():
	first_names = Array(_first_names.split(","))
	last_names = Array(_last_names.split(","))
	print("Populated name lists...")

func get_gnome_name():
	return first_names.pick_random() + " " + last_names.pick_random()

func _populate_gnome_piece_data():
	for appendage_type in SocketInfo.SocketType:
		socket_to_pieces[appendage_type] = []
	
	for resource_path in DirAccess.get_files_at(gnome_pieces_path):
		var item = load(gnome_pieces_path + resource_path) as Appendage
		socket_to_pieces[SocketInfo.SocketType.keys()[item.socket_type]].append(item)
	print("Populated gnome piece data...")

func _populate_socket_info():
	for resource_path in DirAccess.get_files_at(socket_info_path):
		var item = load(socket_info_path + resource_path) as SocketInfo
		socket_info[item.type] = item
	print("Populated socket info...")

func _ready():
	_populate_name_lists()
	_populate_gnome_piece_data()
	_populate_socket_info()

func random_vector_between_two(vec1 : Vector3, vec2 : Vector3):
	return Vector3(randf_range(vec1.x, vec2.x), randf_range(vec1.y, vec2.y), randf_range(vec1.z, vec2.z))


func get_new_gnome():
	var new_gnome = Gnome.new()
	new_gnome.name = get_gnome_name()
	for socket_type_name in SocketInfo.SocketType.keys():
		var new_appendage = socket_to_pieces[socket_type_name].pick_random()
		var new_socket_info = socket_info[new_appendage.socket_type]
		# do scale randomization
		var scale_modification = Vector3.ONE
		var rotation_modification = Vector3.ZERO
		var position_modification = Vector3.ZERO
		if new_socket_info.scale_x_as_scalar is float:
			var scale_mod = randf_range(1-new_socket_info.scale_transform.x, 1+new_socket_info.scale_transform.x)
			scale_modification = Vector3(scale_mod, scale_mod, scale_mod)
		else:
			scale_modification = random_vector_between_two(Vector3.ONE - new_socket_info.scale_transform, Vector3.ONE + new_socket_info.scale_transform)
		
		rotation_modification = random_vector_between_two(Vector3.ZERO - new_socket_info.rotation_transform, Vector3.ZERO + new_socket_info.rotation_transform)
		position_modification = random_vector_between_two(Vector3.ZERO - new_socket_info.position_transform, Vector3.ZERO + new_socket_info.position_transform)

		new_appendage.scale_modification = scale_modification
		new_appendage.rotation_modification = rotation_modification
		new_appendage.position_modification = position_modification
		
		new_appendage.inherit_parent_scale = new_socket_info.inherit_parent_scale

		new_gnome.socket_to_appendage_data[socket_type_name] = new_appendage
	print(new_gnome)
	return new_gnome
	
	#print(new_gnome.name)
	#print(new_gnome.socket_to_appendage_data)
