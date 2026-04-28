<div align="center">

# 🛡️ AlertNest
### AI-Powered Emergency Notification & Response System

[![Python](https://img.shields.io/badge/Python-3.8%2B-blue?style=flat-square&logo=python)](https://python.org)
[![Django](https://img.shields.io/badge/Django-Channels-green?style=flat-square&logo=django)](https://channels.readthedocs.io/)
[![Flutter](https://img.shields.io/badge/Flutter-Cross--Platform-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-Keras-FF6F00?style=flat-square&logo=tensorflow)](https://tensorflow.org)
[![Status](https://img.shields.io/badge/Status-Hackathon%20MVP-orange?style=flat-square)]()

**AlertNest turns a plain-text emergency report into a classified, prioritized, live-broadcast incident — in milliseconds.**

</div>

---

## 💡 The Problem

Emergency responders waste critical seconds figuring out *what* an incident is and *how urgent* it is. AlertNest eliminates that delay with AI triage and real-time coordination — the moment an alert comes in, every responder knows exactly what to do.

---

## ⚡ Demo Flow

```
User types: "Smoke coming from the server room on floor 3"

        ↓ NLP Classifier

    Category: 🔥 FIRE

        ↓ Emergency Priority Engine

    Priority Score: 9.2 / 10  →  CRITICAL

        ↓ WebSocket broadcast

    All responder dashboards update instantly ✅
```

Run it yourself in under 30 seconds:
```bash
cd backend && python demo_epe.py
```

---

## 🧠 AI Engine

AlertNest uses a **dual-model pipeline** — both models are pre-trained and ready to run.

### Model 1 — NLP Classifier (`nlp_model.keras`)
A TensorFlow/Keras Dense Neural Network that reads free-text reports and outputs an intent category.

| Input Text | Classified As |
|---|---|
| `"Smoke in the lobby"` | `🔥 FIRE` |
| `"Person collapsed near entrance"` | `🚑 MEDICAL` |
| `"Suspicious individual on floor 3"` | `🔒 SECURITY` |

### Model 2 — Emergency Priority Engine (`epe_model.keras`)
A dual-input regression model that scores incidents across **severity**, **risk**, and **urgency** — so the most critical alerts always surface first.

> ✅ Pre-trained weights are included. No retraining required to run the system.

---

## 🏗️ Architecture

```
AlertNest/
├── backend/                   # Python Django ASGI server
│   ├── alertnest/             # Project config & settings
│   ├── core/                  # WebSocket routing, incident logic
│   ├── nlp_model.keras        # Pre-trained NLP classifier
│   ├── epe_model.keras        # Pre-trained Priority Engine
│   ├── tokenizer.json         # Word index for NLP model
│   └── demo_epe.py            # Standalone AI demo script
│
└── frontend/                  # Flutter cross-platform app
    └── lib/                   # Dart source & UI components
```

| Layer | Technology |
|---|---|
| Backend | Python Django + Django Channels |
| AI / ML | TensorFlow / Keras |
| Real-time | WebSockets (Daphne ASGI) |
| Database | SQLite via Django ORM |
| Frontend | Flutter (Android, iOS, Web, Desktop) |

---

## 🚀 Getting Started

### Prerequisites
- Python 3.8+ (3.12 recommended)
- Flutter SDK — [Install Guide](https://flutter.dev/docs/get-started/install)

---

### Backend

```bash
git clone https://github.com/nalindotexe/AlertNest.git
cd AlertNest/backend

# Set up virtual environment
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env

# Initialize database
python manage.py migrate

# Start the server
python manage.py runserver 0.0.0.0:8000
```

| | URL |
|---|---|
| API | `http://127.0.0.1:8000/` |
| WebSocket | `ws://127.0.0.1:8000/ws/` |

---

### Frontend

```bash
cd AlertNest/frontend

flutter pub get
flutter run                     # Device / emulator
flutter run -d chrome           # Web browser
```

**Linux Desktop (first time only):**
```bash
flutter config --enable-linux-desktop
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
flutter run -d linux
```

---

## ✨ Key Features

| Feature | Detail |
|---|---|
| 🤖 Instant AI Triage | Free-text → classified type + priority score in one pipeline call |
| 📡 Live Dashboard | WebSocket-powered — zero page refresh, zero delay |
| 🎯 Smart Prioritization | Regression model ranks by severity, risk & urgency |
| ✅ One-Click Resolve | Clears the incident from every connected responder screen simultaneously |
| 🌐 Cross-Platform | Flutter runs on Android, iOS, Web, and Linux Desktop |
| 👥 Dual Role System | Separate flows for guests (reporting) and staff (triage & response) |
| 💬 Live Team Chat | Per-incident team channel synced via WebSocket |

---

## 🔁 Retraining the Models *(Optional)*

Only needed if you want to rebuild the AI from scratch with new data.

```bash
# 1. Retrain NLP Classifier
python train_model.py           # GPU
python train_model_cpu.py       # CPU fallback

# 2. Generate synthetic EPE training data
python generate_epe_data.py

# 3. Retrain Emergency Priority Engine
python train_epe.py
```

---

<div align="center">
  <sub>Built for rapid emergency response · Hackathon MVP</sub>
</div>
