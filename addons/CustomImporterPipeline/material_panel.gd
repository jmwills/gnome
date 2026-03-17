# material_panel.gd
@tool
extends Control

# This holds the reference to the editable settings resource (MaterialConfig)
var config_resource: MaterialConfig = null

func _ready():
    # Set up the UI layout (a simple container)
    name = "Auto Material Config"
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL

    # Create the inspector editor (Godot does the hard work)
    var inspector = EditorInspector.new()
    add_child(inspector)
    inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
    inspector.autocollapse = true
    
    # Set the target object/resource to edit
    if config_resource:
        inspector.set_object(config_resource)