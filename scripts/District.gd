# res://scripts/district.gd
extends Control
class_name District  # Optional: Assign a class name for easier referencing

var webcytes = {}
var current_selected_slot = -1
@onready var grid_container: GridContainer = get_node("GridContainer")
@onready var resource_generator: Timer = get_node_or_null("ResourceGenerator")

# Preload the Webcyte Collection popup scene
var webcyte_collection_popup_scene: PackedScene = preload("res://scenes/ui/WebcyteCollectionPopup.tscn")

# Preload the WorldMap scene
var world_map_scene_path = "res://scenes/world/WorldMap.tscn"

var district_name = ""  # Will set this in _ready from the scene name

func _ready():
    district_name = name  # Use the scene's name to identify which district we are in
    _load_district_config(district_name)
    
    if resource_generator:
        resource_generator.timeout.connect(Callable(self, "_on_ResourceGenerator_timeout"))
        resource_generator.start()
        print("[INFO] District:", district_name, "initialized and Resource Generator started.")
    else:
        push_error("[ERROR] ResourceGenerator node not found in District scene.")
        return

    # Connect slots as before
    for slot_number in range(1, 7):
        var slot_name = "Slot" + str(slot_number)
        var slot = grid_container.get_node_or_null(slot_name)
        if slot and slot is Webcyte:
            var webcyte_slot = slot as Webcyte
            webcyte_slot.pressed.connect(Callable(self, "_on_Slot_pressed").bind(slot_number))
            if webcyte_slot.has_signal("long_pressed"):
                webcyte_slot.long_pressed.connect(Callable(self, "_on_Slot_long_pressed").bind(slot_number))
            add_webcyte_to_slot(slot_number, webcyte_slot)
    
    # Connect the BackButton (make sure the node name matches exactly)
    var back_button = get_node_or_null("BackButton")
    if back_button and back_button is Button:
        back_button.pressed.connect(_on_BackButton_pressed)
    else:
        print("[WARNING] BackButton not found or not a Button.")

func _on_BackButton_pressed():
    # When the back button is pressed, go back to the WorldMap scene
    get_tree().change_scene_to_file(world_map_scene_path)

func _load_district_config(district_name: String):
    if FileAccess.file_exists("res://data/district_config.json"):
        var f = FileAccess.open("res://data/district_config.json", FileAccess.READ)
        if f:
            var text = f.get_as_text()
            var json_parser: JSON = JSON.new()
            var error = 0
            var data = json_parser.parse(text, error)

            if typeof(data) == TYPE_DICTIONARY:
                # If there is a config for the district, load starting webcytes if available
                #if data.has(district_name):
                    var ddata = data[district_name]
                    if ddata.has("starting_webcytes"):
                        _assign_starting_webcytes(ddata["starting_webcytes"])

func _assign_starting_webcytes(wclist: Array):
    var slot_idx = 1
    for wc_data in wclist:
        if slot_idx > 6:
            break
        # Instantiate a Webcyte from data (In a real project, use a factory)
        var w_scene = preload("res://scenes/webcyte/Webcyte.tscn")
        var w = w_scene.instantiate() as Webcyte
        w.webcyte_name = wc_data["name"]
        w.element = wc_data["element"]
        w.level = wc_data.get("level", 1)
        add_webcyte_to_slot(slot_idx, w)
        slot_idx += 1

# --- Function to Assign Webcytes to Slots ---
func assign_webcytes_to_slots():
    var slot_count = 6  # Total number of slots: Slot1 to Slot6
    var webcyte_count = webcytes.size()

    if webcyte_count > slot_count:
        push_error("[ERROR] Number of webcytes exceeds available slots.")
        webcyte_count = slot_count  # Limit to available slots

    for slot_number in range(1, slot_count + 1):
        var slot = webcytes.get(slot_number, null)
        if slot:
            print("[INFO] Slot", slot_number, "has Webcyte:", slot.webcyte_name)

func assign_webcyte_data(
    slot_number: int, webcyte_name: String, element: String, species: String,
    level: int, abilities: Array, img_normal: Texture2D, img_pressed: Texture2D, img_hover: Texture2D,
    upgrade_cost: int, resource_generation: int
):
    var slot = webcytes.get(slot_number, null)
    if slot:
        print("[DEBUG] Assigning Webcyte to Slot:", slot_number)
        slot.webcyte_name = webcyte_name
        slot.element = element
        slot.species = species
        slot.level = level
        slot.abilities = abilities

        slot.img_normal = img_normal
        slot.img_pressed = img_pressed
        slot.img_hover = img_hover

        slot.texture_normal = img_normal
        slot.texture_pressed = img_pressed
        slot.texture_hover = img_hover

        slot.upgrade_cost = upgrade_cost
        slot.resource_generation = resource_generation

        print("[INFO] Assigned Webcyte:", webcyte_name, "to Slot:", str(slot_number))
    else:
        push_error("[ERROR] Slot " + str(slot_number) + " is missing or not a Webcyte.")

func clear_webcyte_slot(slot_number: int):
    var slot = webcytes.get(slot_number, null)
    if slot:
        slot.webcyte_name = "Empty"
        slot.element = ""
        slot.species = ""
        slot.level = 0
        slot.abilities = []
        slot.img_normal = preload("res://assets/images/default_normal.png")
        slot.img_pressed = preload("res://assets/images/default_pressed.png")
        slot.img_hover = preload("res://assets/images/default_hover.png")
        slot.upgrade_cost = 50
        slot.resource_generation = 10

        slot.texture_normal = slot.img_normal
        slot.texture_pressed = slot.img_pressed
        slot.texture_hover = slot.img_hover

        print("[INFO] Cleared Slot" + str(slot_number))
    else:
        push_error("[ERROR] Slot " + str(slot_number) + " does not contain a Webcyte or was not found.")

func _on_Slot_pressed(slot_number: int):
    if webcytes.has(slot_number):
        var webcyte_instance = webcytes[slot_number]
        _handle_elemental_tap(webcyte_instance)
    else:
        print("[INFO] No Webcyte in Slot", slot_number)

func _on_Slot_long_pressed(slot_number: int):
    current_selected_slot = slot_number
    open_webcyte_collection_popup()

func _input(event: InputEvent):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var mouse_pos = event.position
        if not grid_container.get_global_rect().has_point(mouse_pos):
            print("[INFO] District background clicked. Generating resources...")
            _generate_resources()

func _generate_resources():
    var generated_amount = int(100 * ResourceManager.resource_generation_multiplier)
    ResourceManager.add_resource(generated_amount)
    print("[INFO] Generated", generated_amount, "resources.")

func open_webcyte_collection_popup():
    var popup = webcyte_collection_popup_scene.instantiate()
    if popup:
        popup.set_selected_slot(current_selected_slot)
        popup.connect("webcyte_selected", Callable(self, "_on_Webcyte_selected_from_popup"))
        add_child(popup)
        popup.popup_centered()
        print("[INFO] Webcyte Collection popup opened for Slot", str(current_selected_slot))

func _on_Webcyte_selected_from_popup(selected_webcyte: Webcyte):
    if current_selected_slot == -1:
        push_error("[ERROR] No slot selected for Webcyte assignment.")
        return

    var slot = webcytes.get(current_selected_slot, null)
    if slot:
        slot.webcyte_name = selected_webcyte.webcyte_name
        slot.element = selected_webcyte.element
        slot.species = selected_webcyte.species
        slot.level = selected_webcyte.level
        slot.abilities = selected_webcyte.abilities
        slot.img_normal = selected_webcyte.img_normal
        slot.img_pressed = selected_webcyte.img_pressed
        slot.img_hover = selected_webcyte.img_hover
        slot.upgrade_cost = selected_webcyte.upgrade_cost
        slot.resource_generation = selected_webcyte.resource_generation

        slot.texture_normal = selected_webcyte.img_normal
        slot.texture_pressed = selected_webcyte.img_pressed
        slot.texture_hover = selected_webcyte.img_hover

        print("[INFO] Assigned Webcyte", selected_webcyte.webcyte_name, "to Slot", str(current_selected_slot))
    else:
        push_error("[ERROR] Slot " + str(current_selected_slot) + " is not found.")
    
    current_selected_slot = -1

func _handle_elemental_tap(webcyte: Webcyte):
    match webcyte.element.to_lower():
        "fire":
            _handle_fire_element(webcyte)
        "water":
            _handle_water_element(webcyte)
        "earth":
            _handle_earth_element(webcyte)
        "air":
            _handle_air_element(webcyte)
        _:
            print("[WARNING] Unknown element:", webcyte.element)

func _handle_fire_element(webcyte: Webcyte):
    var bonus = 20 * webcyte.level
    if ResourceManager.spend_resource_credits(bonus):
        ResourceManager.add_resource(bonus * 2)
        print("[INFO] Fire Element tapped! Generated", bonus * 2, "resources.")
    else:
        print("[ERROR] Not enough Resource Credits to perform Fire Element tap.")

func _handle_water_element(webcyte: Webcyte):
    webcyte.resource_generation += 5
    print("[INFO] Water Element tapped! Resource generation increased to", webcyte.resource_generation)

func _handle_earth_element(webcyte: Webcyte):
    ResourceManager.set_resource_generation_multiplier(1.5, 30.0)
    print("[INFO] Earth Element tapped! Resource generation rate increased by 50% for 30 seconds.")

func _handle_air_element(webcyte: Webcyte):
    ResourceManager.set_upgrade_speed_multiplier(2.0, 30.0)
    print("[INFO] Air Element tapped! Upgrade speed doubled for 30 seconds.")

func add_webcyte_to_slot(slot_number: int, webcyte_instance: Webcyte):
    webcytes[slot_number] = webcyte_instance
    print("[INFO] Added", webcyte_instance.webcyte_name, "to Slot", slot_number)
