# scripts/ResourceManager.gd
extends Node

# Singleton variables
var resource_credits: int = 1000
var resource_generation_multiplier: float = 1.0
var upgrade_speed_multiplier: float = 1.0

# Methods
func spend_resource_credits(amount: int) -> bool:
    if resource_credits >= amount:
        resource_credits -= amount
        print("[ResourceManager] Spent", amount, "credits. Remaining:", resource_credits)
        return true
    else:
        print("[ResourceManager] Not enough credits to spend.")
        return false

func add_resource(amount: int):
    resource_credits += amount
    print("[ResourceManager] Added", amount, "credits. Total:", resource_credits)

func set_resource_generation_multiplier(multiplier: float, duration: float = 30.0):
    resource_generation_multiplier = multiplier
    print("[ResourceManager] Resource generation multiplier set to", multiplier)
    # Optionally, handle resetting after duration

func set_upgrade_speed_multiplier(multiplier: float, duration: float = 30.0):
    upgrade_speed_multiplier = multiplier
    print("[ResourceManager] Upgrade speed multiplier set to", multiplier)
    # Optionally, handle resetting after duration
