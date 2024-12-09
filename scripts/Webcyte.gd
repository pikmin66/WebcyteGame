# scripts/Webcyte.gd
extends TextureButton
class_name Webcyte

# Webcyte Properties
@export var webcyte_name: String = "DefaultWebcyte"
@export var element: String = "Fire"
@export var species: String = "Dragon"
@export var level: int = 1
@export var abilities = []

# Textures
@export var img_normal: Texture2D
@export var img_pressed: Texture2D
@export var img_hover: Texture2D

# Additional Properties
@export var upgrade_cost: int = 50
@export var resource_generation: int = 10

# Long Press Detection
signal long_pressed

var long_press_duration = 0.5  # Seconds to detect long press
var timer: Timer

func _ready():
    print("Webcyte Ready:", webcyte_name)
    
    # Initialize Timer for Long Press
    timer = Timer.new()
    timer.wait_time = long_press_duration
    timer.one_shot = true
    add_child(timer)
    timer.connect("timeout", Callable(self, "_on_LongPress_timeout"))
    
    # Connect the "pressed" signal
    self.connect("pressed", Callable(self, "_on_pressed"))
    print("[DEBUG] Webcyte Ready:", webcyte_name)
    
    # Ensure textures are assigned at runtime
    if img_normal:
        texture_normal = img_normal
    if img_pressed:
        texture_pressed = img_pressed
    if img_hover:
        texture_hover = img_hover
    

func _on_pressed():
    # Start the timer when pressed
    timer.start()

func _on_released():
    if timer.is_stopped():
        # Timer stopped means it was a short press
        # Emit the standard "pressed" signal
        emit_signal("pressed")
    else:
        # Timer is still running, so it's a long press
        timer.stop()
        emit_signal("long_pressed")

func _on_LongPress_timeout():
    # Timer completed without button release, consider it a long press
    emit_signal("long_pressed")

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            _on_released()

# --- Upgrade Method ---
func upgrade():
    level += 1
    upgrade_cost = 50 * level  # Example scaling
    resource_generation += 5  # Example increment
    print(webcyte_name, "upgraded to level", level)
    
func _on_Webcyte_pressed():
    print("[DEBUG] Pressed Webcyte:", webcyte_name)
