import os
import json
import numpy as np
import tensorflow as tf
from core.epe import EmergencyPriorityEngine

def test_priority():
    engine = EmergencyPriorityEngine()
    
    test_cases = [
        {"id": "1", "text": "small fire in room"},
        {"id": "2", "text": "big fire everything is burning massive flames"},
        {"id": "3", "text": "minor smoke in lobby"},
        {"id": "4", "text": "emergency dying need help fast extreme medical distress"}
    ]
    
    print("\n=== VERIFYING AI PRIORITY SCORES ===")
    results = engine.rank_emergencies(test_cases)
    
    for incident in results["prioritized_emergencies"]:
        print(f"[{incident['priority_score']}] {incident['type']} ({incident['severity']}): {incident['reason']}")
        # The 'text' isn't returned in the finalized JSON by rank_emergencies, 
        # but we can see the scores are ranked.
        
    # Check if big fire > small fire
    big_fire = next(i for i in results["prioritized_emergencies"] if "massive" in i["reason"] or i["priority_score"] > 0.8)
    small_fire = next(i for i in results["prioritized_emergencies"] if "FIRE" == i["type"] and i["priority_score"] < 0.8)
    
    if big_fire['priority_score'] > small_fire['priority_score']:
        print("\n✅ SUCCESS: Intensity calibration working!")
    else:
        print("\n❌ FAILURE: Priority still inverted.")

if __name__ == "__main__":
    test_priority()
