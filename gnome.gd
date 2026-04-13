class_name Gnome extends Resource

enum GNOME_PIECE_TYPES {
	BODY,
	EAR,
	EYE,
	HAT,
	HEAD,
	LEG,
	MOUTH,
	NOSE

}

var color_map : Dictionary[String, Color] = {
	"eye":Color.WHITE,
	"pupil":Color.BLACK,
	"head":Color.BROWN,
	"hat":Color.RED,
	"ear":Color.ROSY_BROWN,
	"nose":Color.DARK_RED,
	"body":Color.LIGHT_GOLDENROD,
	"leg":Color.BLACK,
	"mouth":Color.BROWN,
	"beard":Color.WHITE_SMOKE,
}

@export var gnome_name : String

@export var skeleton_pieces : Dictionary[GNOME_PIECE_TYPES, PackedScene]

@export var attributes : Dictionary ={
	"speed":1.0
}