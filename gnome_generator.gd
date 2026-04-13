extends Node

var _last_names = "Durst,Furst,Kurst,Trest,Melpy,Mergins,Happness,Broond,Ash,Lamp"
var _first_names = "Mee,Gee,Jee,Flee,Boo,Stoo,Fern,Broom,Floom,Thimble,Clem,Sadey,Femmy,Humble,Broogin,Dergin,Stren,Wee,Woh,Clew,Oil,Plen"

@export_dir var gnome_pieces_folder : String

var _palette_key = {
	1 : ["eye", "beard"],
	2 : ["leg", "pupil"],
	3 : ["body"],
	4 : ["head"],
	5 : ["nose", "ear", "mouth"],
	6 : ["hat"],
}

var _palettes = {
	1 : ["edede9","d6ccc2","f5ebe0","e3d5ca","d5bdaf"], #whites of eyes, beard (light)
	2 : ["11151c", "031911", "070707"], # leg, pupil (dark)
	3 : ["79addc","ffc09f","ffee93","fcf5c7","adf7b6"], # body
	4 : ["f7d3bc","f9ae89","d43336","c29b47","49362f","292114","fb5350","69483e","e2d4c5","2e221c"], # skin
	5 : ["fadde1","ffc4d6","ffa6c1","ff87ab","ff5d8f","ff97b7","ffacc5","ffcad4","f4acb7"], # peachy
	6 : ["e2e2df","d2d2cf","e2cfc4","f7d9c4","faedcb","c9e4de","c6def1","dbcdf0","f2c6de","f9c6c9"],
}

func generate_gnome() -> Gnome:
	var new_gnome = Gnome.new()
	
	# 1. Generate Random Name
	var firsts =Array(_first_names.split(","))
	var lasts = Array(_last_names.split(","))
	new_gnome.gnome_name = firsts.pick_random() + " " + lasts.pick_random()
	
	# 2. Assign Random Pieces
	# We iterate through the keys of the enum to ensure we cover every required part
	for piece_type in Gnome.GNOME_PIECE_TYPES.values():
		var piece_scene = _get_random_piece_from_folder(piece_type)
		print(piece_scene)
		if piece_scene:
			new_gnome.skeleton_pieces[piece_type] = piece_scene

	generate_palette(new_gnome)

	return new_gnome

func generate_palette(gnome : Gnome):
	for idx in _palette_key.keys():
		var palette_color = _palettes[idx].pick_random()
		for map_name in _palette_key[idx]:
			gnome.color_map[map_name] = Color.from_string(palette_color, Color.WEB_PURPLE)

func _get_random_piece_from_folder(type: int) -> PackedScene:
	# Convert enum key (e.g., BODY) to lowercase string (e.g., "body")
	var type_name = Gnome.GNOME_PIECE_TYPES.keys()[type].to_lower()
	var folder_path = gnome_pieces_folder.path_join(type_name)
	
	if not DirAccess.dir_exists_absolute(folder_path):
		push_warning("Folder missing for gnome piece: ", folder_path)
		return null
		
	var files = DirAccess.get_files_at(folder_path)
	var scene_files = []
	
	# Filter for scene files specifically (tscn or scn)
	for f in files:
		if f.ends_with(".tscn") or f.ends_with(".scn") or f.ends_with(".gltf"):
			scene_files.append(f)
			
	if scene_files.size() == 0:
		push_warning("No scenes found in: ", folder_path)
		return null
		
	var random_scene_path = folder_path.path_join(scene_files.pick_random())
	return load(random_scene_path)
