import json
import random

def get_text_intensity(text):
    text_lower = text.lower()
    # Boost severity for high intensity terms
    if any(w in text_lower for w in [
        'big', 'huge', 'massive', 'out of control', 'everything', 'burning', 'extreme', 
        'flames', 'badi', 'dodda', 'periya', 'pedda', 'bhayankara', 'bhayanak'
    ]):
        return random.randint(8, 10)
    # Lower severity for low intensity terms
    if any(w in text_lower for w in [
        'small', 'minor', 'little', 'tiny', 'smoke only', 'control', 'choti', 'sanna', 
        'chinna', 'konchem', 'swalpa'
    ]):
        return random.randint(1, 3)
    return random.randint(4, 7) # Default medium

def calculate_priority(category, severity, people_affected, people_at_risk, time_mins):
    # Base weight by category mapping
    # 0 = FIRE, 1 = MEDICAL, 2 = SECURITY
    base = 0.0
    if category == 0:
        base += 0.4
    elif category == 1:
        base += 0.3
    else:
        base += 0.1
        
    # Heuristic impact logic for training data regression targets
    score = base + (severity * 0.03) + (people_affected * 0.005) + (people_at_risk * 0.002) - (time_mins * 0.001)
    
    # Sigmoidal squash boundaries
    return max(0.0, min(1.0, score))

def main():
    print("Loading base linguistic dataset...")
    try:
        with open("training_data.json", "r", encoding="utf-8") as f:
            raw_data = json.load(f)
    except FileNotFoundError:
        print("Error: Ensure training_data.json exists from generate_data.py")
        return
        
    epe_data = []
    
    print("Generating Intensity-Correlated EPE features and Priority Targets...")
    for item in raw_data:
        # Generate 5 variations for each linguistic sample (reduced from 10 to focus quality)
        for _ in range(5):
            # DETECT INTENSITY FROM TEXT (Crucial fix for priority logic)
            severity = get_text_intensity(item["text"])
            
            # Simulate realistic parsed conditions
            people_affected = random.randint(0, 50)
            people_at_risk = random.randint(0, 100)
            time_reported_mins = random.uniform(0, 120)
            
            target = calculate_priority(
                category=item["label"],
                severity=severity,
                people_affected=people_affected, 
                people_at_risk=people_at_risk,
                time_mins=time_reported_mins
            )
            
            epe_data.append({
                "text": item["text"],
                "nlp_category": item["label"],
                "severity": severity,
                "people_affected": people_affected,
                "people_at_risk": people_at_risk,
                "time_reported_mins": time_reported_mins,
                "priority_score": target
            })
        
    with open("epe_training_data.json", "w", encoding="utf-8") as f:
        json.dump(epe_data, f, ensure_ascii=False, indent=2)
        
    print(f"Generated {len(epe_data)} EPE composite samples to epe_training_data.json")

if __name__ == "__main__":
    main()
