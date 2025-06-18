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
'''


def replace_if_trouble_label(input_string):
    if input_string == "Whale vocalization":
        return "Whale"
    elif input_string == "Bird vocalization, bird call, bird song":
        return "Bird"
    elif input_string == "Roaring cats (lions, tigers)": # BOHHH CHE SI FAAAA???
        return "Lion"
    elif input_string == "Motor vehicle (road)":
        return "Motor vehicle" 
    elif input_string == "Police car (siren)":
        return "Police car"
    elif input_string == "Ambulance (siren)":
        return "Ambulance"
    elif input_string == "Fire engine, fire truck (siren)":
        return "Fire truck"
    elif input_string == "Light engine (high frequency)": # BOHHH CHE SI FAAAA???
        return "Light engine"
    elif input_string == "Medium engine (mid frequency)": # BOHHH CHE SI FAAAA???
        return "Medium engine"
    elif input_string == "Heavy engine (low frequency)": # BOHHH CHE SI FAAAA???
        return "Heavy engine"
    elif input_string == "Cupboard open or close":
        return "Cupboard"
    elif input_string == "Drawer open or close":
        return "Drawer"
    elif input_string == "Filing (rasp)":
        return "Rasp"
    elif input_string == "Wind noise (microphone)":
        return "Wind"
    