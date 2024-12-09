# scripts/District.gd
extends Control

# Preload the Webcyte Collection popup scene
var webcyte_collection_popup_scene: PackedScene = preload("res://scenes/ui/WebcyteCollectionPopup.tscn")

# Dictionary to store Webcytes in slots
var webcytes = {}  # Key: slot_number (int), Value: Webcyte instance

# Timer node for resource generation
@onready var resource_generator: Timer = get_node_or_null("ResourceGenerator") as Timer

# Reference to GridContainer
@onready var grid_container: GridContainer = get_node("GridContainer") as GridContainer

# Variable to store the currently selected slot for assignment
var current_selected_slot: int = -1

func _ready():
    if resource_generator:
        # Connect the Resource Generator Timer using Callable
        resource_generator.timeout.connect(Callable(self, "_on_ResourceGenerator_timeout"))
        resource_generator.start()
        print("[INFO] District initialized and Resource Generator started.")
    else:
        push_error("[ERROR] ResourceGenerator node not found in District scene.")
        return  # Exit _ready() to prevent further errors

    # Debug: List all Webcyte nodes within GridContainer
    print("[DEBUG] Listing all children of GridContainer:")
    for child in grid_container.get_children():
        print(" - ", child.name, "(", child.get_class(), ")")

    # Connect signals for all slots within GridContainer
    for slot_number in range(1, 7):
        var slot_name = "Slot" + str(slot_number)
        var slot = grid_container.get_node_or_null(slot_name)
        if slot:
            if slot is Webcyte:
                # Safe to cast now
                var webcyte_slot = slot as Webcyte
                # Connect the "pressed" signal for single taps using Callable with binding
                webcyte_slot.pressed.connect(Callable(self, "_on_Slot_pressed").bind(slot_number))

                # Connect the "long_pressed" signal for long presses
                if webcyte_slot.has_signal("long_pressed"):
                    webcyte_slot.long_pressed.connect(Callable(self, "_on_Slot_long_pressed").bind(slot_number))
                    print("[INFO] Connected 'long_pressed' signal for", slot_name)
                else:
                    print("[WARNING] " + slot_name + " does not have a 'long_pressed' signal.")

                print("[INFO] Connected 'pressed' signal for", slot_name)

                # Assign to webcytes dictionary
                add_webcyte_to_slot(slot_number, webcyte_slot)
            else:
                push_error("[ERROR] " + slot_name + " is not a Webcyte. Actual class: " + slot.get_class())
        else:
            push_error("[ERROR] " + slot_name + " is missing.")



# --- Function to Assign Webcytes to Slots ---
func assign_webcytes_to_slots():
    var slot_count = 6  # Total number of slots: Slot1 to Slot6
    var webcyte_count = webcytes.size()

    if webcyte_count > slot_count:
        push_error("[ERROR] Number of webcytes exceeds available slots.")
        webcyte_count = slot_count  # Limit to available slots

    # Example: Assigning existing Webcyte nodes already set in the editor
    # If you want to dynamically assign Webcytes, adjust accordingly

    # Clear any existing assignments beyond current setup
    for slot_number in range(1, slot_count + 1):
        var slot = webcytes.get(slot_number, null)
        if slot:
            # Ensure that slots have default or initial Webcyte data
            # This step can be customized as per your game's logic
            print("[INFO] Slot", slot_number, "has Webcyte:", slot.webcyte_name)

# --- Function to Assign Webcyte Data ---
func assign_webcyte_data(
    slot_number: int, webcyte_name: String, element: String, species: String,
    level: int, abilities: Array, img_normal: Texture2D, img_pressed: Texture2D, img_hover: Texture2D,
    upgrade_cost: int, resource_generation: int
):
    var slot = webcytes.get(slot_number, null)
    if slot:
        print("[DEBUG] Assigning Webcyte to Slot:", slot_number)

        # Assign properties
        slot.webcyte_name = webcyte_name
        slot.element = element
        slot.species = species
        slot.level = level
        slot.abilities = abilities

        # Correct texture assignment
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



# --- Function to Clear a Webcyte Slot ---
func clear_webcyte_slot(slot_number: int):
    var slot = webcytes.get(slot_number, null)
    if slot:
        # Reset the Webcyte node to default or empty state
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

        # Assign placeholder textures
        slot.texture_normal = slot.img_normal
        slot.texture_pressed = slot.img_pressed
        slot.texture_hover = slot.img_hover

        print("[INFO] Cleared Slot" + str(slot_number))
    else:
        push_error("[ERROR] Slot" + str(slot_number) + " does not contain a Webcyte or was not found.")



# --- Handle Slot Pressed (Single Tap) ---
func _on_Slot_pressed(slot_number: int):
    if webcytes.has(slot_number):
        var webcyte_instance = webcytes[slot_number]
        _handle_elemental_tap(webcyte_instance)
    else:
        print("[INFO] No Webcyte in Slot", slot_number)

# --- Handle Slot Long Press (Open Webcyte Collection Popup) ---
func _on_Slot_long_pressed(slot_number: int):
    current_selected_slot = slot_number
    open_webcyte_collection_popup()

# Override to Handle Clicks on District Background
func _input(event: InputEvent):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var mouse_pos = event.position
        
        # Ensure click happens **outside** the collection grid
        if not grid_container.get_global_rect().has_point(mouse_pos):
            print("[INFO] District background clicked. Generating resources...")
            _generate_resources()


# Generate Resources Using ResourceManager
func _generate_resources():
    var generated_amount = int(100 * ResourceManager.resource_generation_multiplier)
    ResourceManager.add_resource(generated_amount)
    print("[INFO] Generated", generated_amount, "resources.")
    
# --- Open Webcyte Collection Popup ---
func open_webcyte_collection_popup():
    var popup = webcyte_collection_popup_scene.instantiate()
    if popup:
        popup.set_selected_slot(current_selected_slot)
        popup.connect("webcyte_selected", Callable(self, "_on_Webcyte_selected_from_popup"))
        add_child(popup)
        popup.popup_centered()
        print("[INFO] Webcyte Collection popup opened for Slot", str(current_selected_slot))


# Handle Webcyte Selection from Popup
func _on_Webcyte_selected_from_popup(selected_webcyte: Webcyte):
    if current_selected_slot == -1:
        push_error("[ERROR] No slot selected for Webcyte assignment.")
        return

    # Fetch the relevant slot
    var slot = webcytes.get(current_selected_slot, null)
    if slot:
        # Assign textures directly to the slot's button properties
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

        # Update the slot's texture
        slot.texture_normal = selected_webcyte.img_normal
        slot.texture_pressed = selected_webcyte.img_pressed
        slot.texture_hover = selected_webcyte.img_hover

        print("[INFO] Assigned Webcyte", selected_webcyte.webcyte_name, "to Slot", str(current_selected_slot))
    else:
        push_error("[ERROR] Slot " + str(current_selected_slot) + " is not found.")
    
    current_selected_slot = -1  # Reset after assignment



# --- Handle Elemental Tap ---
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

# --- Define Elemental Handlers ---
func _handle_fire_element(webcyte: Webcyte):
    var bonus = 20 * webcyte.level
    if ResourceManager.spend_resource_credits(bonus):
        ResourceManager.add_resource(bonus * 2)  # Example: double the spent credits
        print("[INFO] Fire Element tapped! Generated", bonus * 2, "resources.")
    else:
        print("[ERROR] Not enough Resource Credits to perform Fire Element tap.")

func _handle_water_element(webcyte: Webcyte):
    # Example: Boost Webcyte's resource generation temporarily
    webcyte.resource_generation += 5
    print("[INFO] Water Element tapped! Resource generation increased to", webcyte.resource_generation)

func _handle_earth_element(webcyte: Webcyte):
    # Example: Increase resource generation rate temporarily
    ResourceManager.set_resource_generation_multiplier(1.5, 30.0)  # 30 seconds duration
    print("[INFO] Earth Element tapped! Resource generation rate increased by 50% for 30 seconds.")

func _handle_air_element(webcyte: Webcyte):
    # Example: Speed up upgrades or resource collection
    ResourceManager.set_upgrade_speed_multiplier(2.0, 30.0)  # 30 seconds duration
    print("[INFO] Air Element tapped! Upgrade speed doubled for 30 seconds.")

# --- Function to Add Webcytes to Slots ---
func add_webcyte_to_slot(slot_number: int, webcyte_instance: Webcyte):
    webcytes[slot_number] = webcyte_instance
    print("[INFO] Added", webcyte_instance.webcyte_name, "to Slot", slot_number)
    # Optionally, update the slot's texture to represent the Webcyte
