@tool
extends EditorPlugin

var import_plugin := preload("import_plugin.gd").new()


func _enter_tree():
	add_scene_post_import_plugin(import_plugin)


func _exit_tree():
	remove_scene_post_import_plugin(import_plugin)