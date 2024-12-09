extends Popup

@export var webcyte_scene: PackedScene = preload("res://scenes/webcyte/Webcyte.tscn")

@onready var grid_container = $GridContainer
@onready var back_button = $BackButton


# Signal to emit when a Webcyte is selected
signal webcyte_selected(webcyte: Webcyte)

# Variable to store the slot number that initiated the popup
var target_slot_number: int = -1

func _ready():
    # Populate Grid with Webcytes
    populate_webcytes()

    # Connect Back Button signal
    back_button.pressed.connect(_on_BackButton_pressed)

    # Correct input blocking
    grid_container.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP



# Handle outside click using `_gui_input`
func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var mouse_pos = get_viewport().get_mouse_position()
        var global_rect = Rect2(position, size)

        # Close the popup if clicked outside
        if not global_rect.has_point(mouse_pos):
            hide()

# Method to set the slot number
func set_selected_slot(slot_number: int):
    target_slot_number = slot_number
    print("[DEBUG] WebcyteCollection Popup opened for Slot " + str(target_slot_number))

# Populate Webcytes in the collection
func populate_webcytes():
    for child in grid_container.get_children():
        child.queue_free()

    var available_webcytes = get_available_webcytes()

    for webcyte_data in available_webcytes:
        var webcyte_instance = webcyte_scene.instantiate() as Webcyte
        if webcyte_instance:
            print("[DEBUG] Instantiating Webcyte:", webcyte_data["webcyte_name"])

            # Assign textures correctly
            webcyte_instance.webcyte_name = webcyte_data["webcyte_name"]
            webcyte_instance.element = webcyte_data["element"]
            webcyte_instance.img_normal = webcyte_data["img_normal"]
            webcyte_instance.img_pressed = webcyte_data["img_pressed"]
            webcyte_instance.img_hover = webcyte_data["img_hover"]

            webcyte_instance.texture_normal = webcyte_data["img_normal"]
            webcyte_instance.texture_pressed = webcyte_data["img_pressed"]
            webcyte_instance.texture_hover = webcyte_data["img_hover"]

            webcyte_instance.mouse_filter = Control.MOUSE_FILTER_STOP

            # Connect click signal
            webcyte_instance.pressed.connect(Callable(self, "_on_Webcyte_pressed").bind(webcyte_instance))

            # Add to grid
            grid_container.add_child(webcyte_instance)
        else:
            push_error("[ERROR] Webcyte instantiation failed.")


func get_available_webcytes() -> Array:
    return [
        {
            "webcyte_name": "Regifire",
            "element": "Fire",
            "species": "Object",
            "level": 1,
            "abilities": [],
            "img_normal": preload("res://assets/images/regifire.png"),
            "img_pressed": preload("res://assets/images/regifire.png"),
            "img_hover": preload("res://assets/images/regifire.png"),
            "upgrade_cost": 50,
            "resource_generation": 10
        },
        {
            "webcyte_name": "Regibug",
            "element": "Insect",
            "species": "Object",
            "level": 1,
            "abilities": [],
            "img_normal": preload("res://assets/images/Regibug.png"),
            "img_pressed": preload("res://assets/images/Regibug.png"),
            "img_hover": preload("res://assets/images/Regibug.png"),
            "upgrade_cost": 50,
            "resource_generation": 10
        }
    ]

# Handle Webcyte selection from the popup
func _on_Webcyte_pressed(webcyte: Webcyte):
    print("[INFO] Selected Webcyte:", webcyte.webcyte_name)
    emit_signal("webcyte_selected", webcyte)
    hide()

# Handle Back Button
func _on_BackButton_pressed():
    hide()
