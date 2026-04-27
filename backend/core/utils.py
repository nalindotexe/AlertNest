import re
import json
import os
import string
import datetime

# --- EMERGENCY GPU PATH FIX ---
# Embed NVIDIA/CUDA paths directly inside the backend process to ensure Django can load the model
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VENV_PATH = os.path.join(BASE_DIR, "venv/lib/python3.12/site-packages/nvidia")

if os.path.exists(VENV_PATH):
    LIB_PATHS = [
        os.path.join(VENV_PATH, "cudnn/lib"),
        os.path.join(VENV_PATH, "cublas/lib"),
        os.path.join(VENV_PATH, "cuda_nvrtc/lib"),
        os.path.join(VENV_PATH, "cuda_runtime/lib")
    ]
    os.environ['LD_LIBRARY_PATH'] = ":".join(LIB_PATHS) + ":" + os.environ.get('LD_LIBRARY_PATH', '')
    os.environ['XLA_FLAGS'] = f"--xla_gpu_cuda_data_dir={os.path.join(VENV_PATH, 'cuda_nvcc')}"

import tensorflow as tf
# ------------------------------

# Load TF Model and Tokenizer
model = None
word_index = None
HAS_TF = False

model_path = os.path.join(BASE_DIR, 'nlp_model.keras')
tokenizer_path = os.path.join(BASE_DIR, 'tokenizer.json')

try:
    if os.path.exists(model_path):
        model = tf.keras.models.load_model(model_path)
        with open(tokenizer_path, 'r') as f:
            word_index = json.load(f)
        HAS_TF = True
    else:
        print(f"Warning: ML Model not found at {model_path}")
except Exception as e:
    print(f"Warning: TensorFlow loading failed: {e}")
    HAS_TF = False

def classify_incident(text: str):
    text_lower = text.lower()
    
    # --- PHASE 1: SAFETY OVERRIDES (NATIVE + TRANSILITERATED) ---
    # We check these first to ensure critical terms like 'benki' are NEVER missed.
    
    # FIRE / IMMEDIATE DANGER
    if any(k in text_lower for k in [
        'fire', 'smoke', 'burn', 'emergency', 'aag', 'agni', 'thee', 'neruppu', 
        'agg', 'baah', 'jui', 'dhuwan', 'dhuman', 'flames', 'shola', 
        'benki', 'hachide', 'aagide', 'ಬೆಂಕಿ', 'ಆಗ', 'தீ'
    ]):
        if any(k in text_lower for k in ['small', 'minor', 'little', 'tiny', 'sanna', 'chota', 'chinna']):
            return ("FIRE", "MEDIUM")
        return ("FIRE", "HIGH")
        
    # MEDICAL / URGENT CARE
    if any(k in text_lower for k in [
        'medical', 'bleed', 'hurt', 'help', 'doctor', 'madad', 'sahay', 'udhavi', 
        'sahayam', 'daktar', 'chikitsa', 'khoon', 'chot', 'behosh', 'faint', 
        'ambulance', 'ಸಹಾಯ', 'உதவி', 'సహాయం'
    ]):
        if any(k in text_lower for k in ['everything', 'dying', 'extreme', 'unconscious', 'massive']):
            return ("MEDICAL", "HIGH")
        return ("MEDICAL", "MEDIUM")

    # SECURITY / THREATS
    if any(k in text_lower for k in [
        'police', 'thief', 'robbery', 'weapon', 'intruder', 'chor', 'chakku', 'loot', 
        'badmash', 'stole', 'stolen', 'donga', 'kalla', 'ತಸ್ಮರ'
    ]):
        if any(k in text_lower for k in ['weapon', 'gun', 'knife', 'chakku', 'massive', 'extreme']):
            return ("SECURITY", "HIGH")
        return ("SECURITY", "LOW")

    # --- PHASE 2: AI CLASSIFICATION (FOR CONTEXTUAL PHRASES) ---
    cat_id = 2 # default Security
    if HAS_TF and model is not None:
        try:
            text_clean = text_lower.translate(str.maketrans('', '', string.punctuation))
            words = text_clean.split()
            seq = [word_index.get(w, 1) for w in words]
            # pad to max_length 64 (matching Accuracy Overhaul v5.0)
            if len(seq) > 64: 
                seq = seq[:64]
            else: 
                seq = seq + [0] * (64 - len(seq))
            
            input_tensor = tf.constant([seq], dtype=tf.int32)
            predictions = model.predict(input_tensor, verbose=0)[0]
            cat_id = int(tf.math.argmax(predictions).numpy())
        except:
            cat_id = 2
            
    mapping = {
        0: ("FIRE", "HIGH"),
        1: ("MEDICAL", "MEDIUM"),
        2: ("SECURITY", "LOW")
    }
    return mapping.get(cat_id, ("SECURITY", "LOW"))

def extract_location(text: str) -> str:
    loc_keywords = [
        r"room", r"floor", r"lobby", r"kitchen", r"stairs", r"parking", r"hall", r"entrance",
        r"kamra", r"manzil", r"rasoee", r"arai", r"thalam", r"gadi", r"anthastu", r"kholi"
    ]
    pattern = r"(" + "|".join(loc_keywords) + r")\s+([a-zA-Z0-9]+)"
    match = re.search(pattern, text, re.IGNORECASE)
    if match: 
        return f"{match.group(1).title()} {match.group(2)}"
    return "Unknown"
