# scripts/WebcyteUpgradePopup.gd
extends Window

var webcyte: Webcyte = null

@onready var upgrade_button: Button = $VBoxContainer/UpgradeButton
@onready var webcyte_info_label: Label = $VBoxContainer/WebcyteInfo
@onready var close_button: Button = $TitleBar/CloseButton  # Adjust path as necessary

func _ready():
    # Connect upgrade and close button signals using Callable
    if upgrade_button:
        upgrade_button.connect("pressed", Callable(self, "_on_UpgradeButton_pressed"))
    else:
        push_error("[ERROR] UpgradeButton not found!")
    
    if close_button:
        close_button.connect("pressed", Callable(self, "_on_CloseButton_pressed"))
    else:
        push_error("[ERROR] CloseButton not found!")
    
    print("[INFO] WebcyteUpgradePopup initialized successfully.")

# Assign Webcyte Data to the Popup
func set_webcyte(webcyte_instance: Webcyte):
    if webcyte_instance == null:
        push_error("[ERROR] Webcyte instance is null!")
        return
    
    webcyte = webcyte_instance
    update_info()

# Update Webcyte Info in Label
func update_info():
    if webcyte == null or webcyte_info_label == null:
        push_error("[ERROR] Webcyte or WebcyteInfo is missing!")
        return
    
    webcyte_info_label.text = "Name: " + webcyte.webcyte_name + \
                              "\nElement: " + webcyte.element + \
                              "\nSpecies: " + webcyte.species + \
                              "\nLevel: " + str(webcyte.level) + \
                              "\nUpgrade Cost: " + str(webcyte.upgrade_cost) + \
                              "\nResource Gen: " + str(webcyte.resource_generation)
    print("[DEBUG] Webcyte info updated:", webcyte_info_label.text)

# Handle Upgrade Button Press
func _on_UpgradeButton_pressed():
    if webcyte == null:
        push_error("[ERROR] Cannot upgrade a null Webcyte!")
        return
    
    if ResourceManager.spend_resource_credits(webcyte.upgrade_cost):
        webcyte.upgrade()
        update_info()
        print("[INFO] Upgraded", webcyte.webcyte_name, "to level", webcyte.level)
    else:
        print("[ERROR] Not enough Resource Credits to upgrade.")

# Handle Close Button Press
func _on_CloseButton_pressed():
    hide()
    print("[INFO] Popup closed.")
