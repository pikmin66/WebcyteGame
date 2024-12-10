# res://scripts/WorldMap.gd
extends Control
class_name WorldMap

@onready var district_list: ItemList = $DistrictList
@onready var select_button: Button = $SelectButton

var districts_data = [
    {"name": "Canvas District", "scene_path": "res://scenes/district/CanvasDistrict.tscn", "element": "Air"},
    {"name": "Teal District", "scene_path": "res://scenes/district/TealDistrict.tscn", "element": "Water"},
    {"name": "Opal District", "scene_path": "res://scenes/district/OpalDistrict.tscn", "element": "Earth"}
    # Add more districts as needed
]

func _ready():
    for d in districts_data:
        district_list.add_item(d.name)
    select_button.pressed.connect(_on_SelectButton_pressed)

func _on_SelectButton_pressed():
    var selected = district_list.get_selected_items()
    if selected.size() == 0:
        print("[INFO] No district selected.")
        return
    var idx = selected[0]
    var chosen = districts_data[idx]
    # Move to the chosen district's scene
    # Optionally, pass district info to the District scene via global GameState or scene arguments
    get_tree().change_scene_to_file(chosen.scene_path)
