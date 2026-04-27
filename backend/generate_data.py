import random
import json

# Data Generator for AlertNest Multilingual AI (v7.0 - Intensity Overhaul)
# Includes intensity descriptors and escalation phrases to fix priority logic.

categories = {
    "FIRE": 0,
    "MEDICAL": 1,
    "SECURITY": 2
}

intensifiers = {
    "high": {
        "English": ["big", "huge", "massive", "out of control", "everything is burning", "extreme", "massive flames"],
        "Hindi": ["badi", "bohot bada", "sab jal raha hai", "bhayanak", "uncontrolled"],
        "Kannada": ["dodda", "thumba dodda", "ella uriyuthide", "bhayankara", "niyantrana illa"],
        "Tamil": ["periya", "romba periya", "ellam eriyuthu", "bayangarama", "kattupaadu illai"],
        "Telugu": ["pedda", "chala pedda", "anni kalipothunnayi", "bhayankaram", "niyantrana ledu"]
    },
    "low": {
        "English": ["small", "minor", "little", "tiny", "smoke only", "under control"],
        "Hindi": ["choti", "thoda", "kam", "niyantrit", "sirf dhuan"],
        "Kannada": ["sanna", "swalpa", "kadime", "niyantranadallide", "hoge mathra"],
        "Tamil": ["chinna", "konjam", "kuraivaana", "kattupaatu kul", "pukai mattum"],
        "Telugu": ["chinna", "konchem", "thakkuva", "niyantranalo undi", "poga mathrame"]
    }
}

languages = {
    "English": {
        "FIRE": ["fire", "smoke", "burning", "flames", "fire in room"],
        "MEDICAL": ["help", "ambulance", "bleeding", "doctor", "emergency", "hurt badly"],
        "SECURITY": ["police", "thief", "robbery", "intruder", "security", "weapon"]
    },
    "Hindi": {
        "FIRE": ["आग", "धुआं", "aag", "dhuan", "jal raha hai", "aag lagi hai"],
        "MEDICAL": ["मदద", "डॉक्टर", "madad", "khoon", "ambulance", "chot", "sahayata"],
        "SECURITY": ["पुलिस", "chor", "police", "chor", "shakki", "badmash", "loot"]
    },
    "Kannada": {
        "FIRE": ["ಬೆಂಕಿ", "ಬೆಂಕಿ ಹಚ್ಚಿದೆ", "ಹೊಗೆ ಬರ್ತಿದೆ", "benki", "hoge", "benki hachide", "benki aagide"],
        "MEDICAL": ["ಸಹಾಯ ಮಾಡಿ", "ಅಂಬ್ಯುಲೆನ್ಸ್ ಬೇಕು", "ರಕ್ತ ಬರ್ತಿದೆ", "ವೈದ್ಯರು", "sahaya", "vaidyaru", "ambulance beku", "raktha barthide"],
        "SECURITY": ["ಕಳ್ಳ ಬಂದಿದ್ದಾನೆ", "ಪೊಲೀಸ್ ಬೇಕು", "ಶಕ್ಕಿ ಇದೆ", "kalla", "police", "kalla bandiddane", "shakki ide", "dongalu"]
    },
    "Tamil": {
        "FIRE": ["தீ விಬத்து", "நெருப்பு", "thee", "neruppu", "pukai", "thee paravugiradhu"],
        "MEDICAL": ["உதவி தேவை", "மருத்துவர்", "udhavi", "sahayam", "ratham", "maruthuvar"],
        "SECURITY": ["காவல்துறை", "திருடன்", "police", "kavalthurai", "thirudan", "police beku"]
    },
    "Telugu": {
        "FIRE": ["అగ్ని ప్రమాదం", "మంటలు", "agni", "mantalu", "mantalu vastunayi"],
        "MEDICAL": ["సహాయం", "వైద్యుడు", "sahayam", "debba", "raktham", "avasaram", "doctor"],
        "SECURITY": ["పోలీసు", "దొంగ", "police", "donga", "dongalthanam", "shakki"]
    }
}

def main():
    dataset = []
    
    # Generate 8,000 samples for high robustness
    for _ in range(8000):
        lang_key = random.choice(list(languages.keys()))
        cat = random.choice(list(categories.keys()))
        
        term = random.choice(languages[lang_key][cat])
        
        # Mix in intensifiers 60% of the time
        if random.random() > 0.4:
            level = random.choice(["high", "low"])
            intensity = random.choice(intensifiers[level][lang_key])
            sentence = f"{intensity} {term}" if random.random() > 0.5 else f"{term} is {intensity}"
        else:
            sentence = term
        
        # Randomly add locations
        if random.random() > 0.4:
            loc = random.choice(["room", "floor", "lobby", "near here", "manzil", "kamra", "stairs", "kitchen"])
            sentence = f"{loc} {sentence}" if random.random() > 0.5 else f"{sentence} in {loc}"
            
        dataset.append({"text": sentence, "label": categories[cat]})
        
    with open("training_data.json", "w", encoding="utf-8") as f:
        json.dump(dataset, f, ensure_ascii=False, indent=2)

    print(f"Generated {len(dataset)} samples (v7.0) with Intensity Descriptors.")

if __name__ == "__main__":
    main()
