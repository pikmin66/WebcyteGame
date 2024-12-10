extends Control

@onready var start_button = $StartButton
@onready var settings_button = $SettingsButton

# Preload WorldMap scene instead of District
var WorldMapScene = preload("res://scenes/world/WorldMap.tscn")

func _ready():
    start_button.connect("pressed", Callable(self, "_on_StartButton_pressed"))
    settings_button.connect("pressed", Callable(self, "_on_SettingsButton_pressed"))

func _on_StartButton_pressed():
    var tree = get_tree()
    var result = tree.change_scene_to_file("res://scenes/world/WorldMap.tscn")
    if result != OK:
        push_error("[ERROR] Failed to change scene to WorldMap.tscn")
    else:
        print("[INFO] Successfully changed to WorldMap.tscn")

func _on_SettingsButton_pressed():
    print("Settings button pressed")
    # Implement settings menu later
