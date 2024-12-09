# scripts/Main.gd
extends Control

# References to UI elements
@onready var start_button = $StartButton
@onready var settings_button = $SettingsButton

# Preload the District scene
var DistrictScene = preload("res://scenes/district/District.tscn")

func _ready():
    # Connect signals using Callable for better error handling
    start_button.connect("pressed", Callable(self, "_on_StartButton_pressed"))
    settings_button.connect("pressed", Callable(self, "_on_SettingsButton_pressed"))

func _on_StartButton_pressed():
    var tree = get_tree()
    print("Tree class: ", tree.get_class())  # Should print "SceneTree"
    print("Has change_scene_to: ", tree.has_method("change_scene_to_file"))  # Should print "True"

    # Change to the District scene using change_scene_to_file
    var result = tree.change_scene_to_file("res://scenes/district/District.tscn")
    if result != OK:
        push_error("[ERROR] Failed to change scene to District.tscn")
    else:
        print("[INFO] Successfully changed to District.tscn")

func _on_SettingsButton_pressed():
    # Open Settings menu (to be implemented)
    print("Settings button pressed")
