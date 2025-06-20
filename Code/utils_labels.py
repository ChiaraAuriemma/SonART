'''
Con termini che possono fuorviare l'immagine:
"Whale vocalization",
"Bird vocalization, bird call, bird song", SIA IN FARM CHE IN FOREST
"Roaring cats (lions, tigers)",
"Motor vehicle (road)",
"Police car (siren)",
"Ambulance (siren)",
"Fire engine, fire truck (siren)",
"Light engine (high frequency)",
"Medium engine (mid frequency)",
"Heavy engine (low frequency)",
"Cupboard open or close",
"Drawer open or close",
"Filing (rasp)",
"Wind noise (microphone)",


Troppo generici:
"Animal",
"Wild animals",
"Domestic animals, pets",
"Music",
"Musical instrument",
"Plucked string instrument",
"Sound effect",
"Siren"
'''



def replace_if_trouble_label(input_string):
    if input_string == "Whale vocalization":
        return "Whale"
    elif input_string == "Bird vocalization, bird call, bird song":
        return "Bird"
    elif input_string == "Roaring cats (lions, tigers)":
        return "Lion"
    elif input_string == "Motor vehicle (road)":
        return "Motor vehicle" 
    elif input_string == "Police car (siren)":
        return "Police car"
    elif input_string == "Ambulance (siren)":
        return "Ambulance"
    elif input_string == "Fire engine, fire truck (siren)":
        return "Fire truck"
    elif input_string == "Light engine (high frequency)":
        return "Light engine"
    elif input_string == "Medium engine (mid frequency)":
        return "Medium engine"
    elif input_string == "Heavy engine (low frequency)":
        return "Heavy engine"
    elif input_string == "Cupboard open or close":
        return "Cupboard"
    elif input_string == "Drawer open or close":
        return "Drawer"
    elif input_string == "Filing (rasp)":
        return "Rasp"
    elif input_string == "Wind noise (microphone)":
        return "Wind"
    
    # Animal sound mappings
    elif input_string in ["Bark", "Yip", "Howl", "Bow-wow", "Growling", "Whimper (dog)"]:
        return "Dog"
    elif input_string in ["Purr", "Meow", "Hiss", "Caterwaul"]:
        return "Cat"
    elif input_string in ["Clip-clop", "Neigh, whinny"]:
        return "Horse"
    elif input_string in ["Moo", "Cowbell"]:
        return "Cattle, bovinae"
    elif input_string == "Oink":
        return "Pig"
    elif input_string == "Bleat":
        return "Goat"  # Note: Sheep also bleat but it's listed under goat in the data
    elif input_string in ["Cluck", "Crowing, cock-a-doodle-doo"]:
        return "Chicken, rooster"
    elif input_string == "Gobble":
        return "Turkey"
    elif input_string == "Quack":
        return "Duck"
    elif input_string == "Honk":
        return "Goose"
    elif input_string == "Roar":
        return "Lion"
    elif input_string in ["Chirp, tweet", "Squawk", "Bird flight, flapping wings"]:
        return "Bird"
    elif input_string == "Coo":
        return "Pigeon, dove"
    elif input_string == "Caw":
        return "Crow"
    elif input_string == "Hoot":
        return "Owl"
    elif input_string == "Patter":
        return "Mouse"
    elif input_string == "Cricket":
        return "Insect"
    elif input_string in ["Buzz", "Mosquito", "Fly, housefly"]:
        return "Insect"
    elif input_string == "Croak":
        return "Frog"
    elif input_string == "Rattle":
        return "Snake"
    
    return input_string
    