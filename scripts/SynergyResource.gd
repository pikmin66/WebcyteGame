# scripts/SynergyResource.gd
extends Resource

# Declare Synergy Properties
@export var synergy_name: String = "Default Synergy"
@export var synergy_type: String = "Elemental"  # "Elemental" | "Species" | "Positional"
@export var required_webcytes: Array[String] = []  # Names of Webcytes needed for synergy
@export var effects: Dictionary = {}  # Define synergy effects

# Check if the synergy is active
func is_active(current_webcytes: Dictionary) -> bool:
    """
    Check if all required Webcytes are present in the district.
    """
    for required in required_webcytes:
        var found = false
        for webcyte in current_webcytes.values():
            if webcyte.webcyte_name == required:
                found = true
                break
        if not found:
            return false
    return true

# Apply effects if synergy is active
func apply_effects(webcytes: Dictionary):
    """
    Apply synergy effects to Webcytes if active.
    """
    for slot in webcytes.keys():
        var webcyte = webcytes[slot]
        for effect_name in effects.keys():
            if webcyte.has(effect_name):
                webcyte.set(effect_name, webcyte.get(effect_name) + effects[effect_name])
