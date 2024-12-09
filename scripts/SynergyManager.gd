# scripts/SynergyManager.gd
extends Node

# Ensure SynergyCollectionResource is recognized
@export var synergy_collection: SynergyCollectionResource = preload("res://data/SynergyCollectionResource.tres")

# Dictionary to track active synergies
var active_synergies: Array = []

func _ready():
    if synergy_collection == null:
        push_error("Failed to load SynergyCollectionResource.tres!")
    else:
        print("Synergy Collection Loaded Successfully")

# Check all synergies based on Webcytes in the grid
func check_synergies(webcytes: Dictionary):
    active_synergies.clear()
    check_elemental_synergies(webcytes)
    check_species_synergies(webcytes)
    check_positional_synergies(webcytes)


# --- Elemental Synergies ---
func check_elemental_synergies(webcytes: Dictionary):
    for synergy in synergy_collection.dual_synergies:
        if synergy.synergy_type == "Elemental" and synergy.is_active(webcytes):
            active_synergies.append(synergy)
            synergy.apply_effects(webcytes)

    for synergy in synergy_collection.triple_synergies:
        if synergy.synergy_type == "Elemental" and synergy.is_active(webcytes):
            active_synergies.append(synergy)
            synergy.apply_effects(webcytes)

# --- Species Synergies ---
func check_species_synergies(webcytes: Dictionary):
    for synergy in synergy_collection.dual_synergies:
        if synergy.synergy_type == "Species" and synergy.is_active(webcytes):
            active_synergies.append(synergy)
            synergy.apply_effects(webcytes)

    for synergy in synergy_collection.triple_synergies:
        if synergy.synergy_type == "Species" and synergy.is_active(webcytes):
            active_synergies.append(synergy)
            synergy.apply_effects(webcytes)

# --- Positional Synergies ---
func check_positional_synergies(webcytes: Dictionary):
    for synergy in synergy_collection.dual_synergies:
        if synergy.synergy_type == "Positional" and synergy.is_active(webcytes):
            active_synergies.append(synergy)
            synergy.apply_effects(webcytes)

    for synergy in synergy_collection.triple_synergies:
        if synergy.synergy_type == "Positional" and synergy.is_active(webcytes):
            active_synergies.append(synergy)
            synergy.apply_effects(webcytes)



# --- Dual/Triple Checking ---
func check_dual_synergy(synergy, webcytes: Dictionary) -> bool:
    var elements_present = []
    for wc in webcytes.values():
        elements_present.append(wc.element)
    for elem in synergy.required_elements:
        if elements_present.count(elem) < synergy.required_elements.count(elem):
            return false
    return true


func check_triple_synergy(synergy, webcytes: Dictionary) -> bool:
    var columns = {1: [], 2: []}
    for slot in webcytes.keys():
        var column = get_column_from_slot(slot)
        columns[column].append(webcytes[slot].element)

    for column_elements in columns.values():
        var found_match = true
        for elem in synergy.required_elements:
            if column_elements.count(elem) < synergy.required_elements.count(elem):
                found_match = false
                break
        if found_match:
            return true
    return false


func check_dual_species_synergy(synergy, webcytes: Dictionary) -> bool:
    var species_present = []
    for wc in webcytes.values():
        species_present.append(wc.species)
    for species in synergy.required_species:
        if species_present.count(species) < synergy.required_species.count(species):
            return false
    return true


func check_triple_species_synergy(synergy, webcytes: Dictionary) -> bool:
    var columns = {1: [], 2: []}
    for slot in webcytes.keys():
        var column = get_column_from_slot(slot)
        columns[column].append(webcytes[slot].species)

    for column_species in columns.values():
        var found_match = true
        for species in synergy.required_species:
            if column_species.count(species) < synergy.required_species.count(species):
                found_match = false
                break
        if found_match:
            return true
    return false


func check_dual_positional_synergy(synergy, webcytes: Dictionary) -> bool:
    for position in synergy.required_positions:
        if not webcytes.has(position):
            return false
    return true


func check_triple_positional_synergy(synergy, webcytes: Dictionary) -> bool:
    var columns = {1: [], 2: []}
    for slot in webcytes.keys():
        var column = get_column_from_slot(slot)
        columns[column].append(slot)

    for column_slots in columns.values():
        var found_match = true
        for position in synergy.required_positions:
            if not column_slots.has(position):
                found_match = false
                break
        if found_match:
            return true
    return false


# --- Utility Functions ---
func get_column_from_slot(slot_number: int) -> int:
    return 1 if slot_number % 2 != 0 else 2


func apply_synergy_effect(synergy):
    for key in synergy.effects.keys():
        var modifiers = synergy.effects[key]
        for wc in get_webcytes_by_element_or_species(key):
            apply_stat_modifiers(wc, modifiers)


func apply_stat_modifiers(wc, modifiers: Dictionary):
    for stat in modifiers.keys():
        if wc.has(stat):
            wc.set(stat, wc.get(stat) + modifiers[stat])


func get_webcytes_by_element_or_species(value: String) -> Array:
    var found_webcytes = []
    for district in get_tree().get_nodes_in_group("District"):
        for slot in district.webcytes.keys():
            var wc = district.webcytes[slot]
            if wc.element == value or wc.species == value:
                found_webcytes.append(wc)
    return found_webcytes
