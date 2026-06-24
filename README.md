
# ⚔️ Sentinel's Spire – 2D Action RPG Engine

**Sentinel's Spire** is a systems-driven 2D Action RPG built in the **Godot Engine**. It translates complex action mechanics into a highly modular backend architecture—perfect for scalable combat, reactive AI entities, and smooth multi-platform control layouts.

This project focuses entirely on the gameplay engineering and core systems architecture. While visual assets (sprites, animations, environment art) are currently in a development/placeholder state, the underlying backend logic, entity structures, and combat systems are fully operational.

---

## ✨ Features

- 🧠 **Decoupled Finite State Machine (FSM):** Clean, state-driven logic for all entities (Player, Enemies, Bosses) managing states like `Idle`, `Move`, `Attack`, `Hurt`, and `Death` without input overlapping.
- ⚔️ **Unified Entity Backend:** A scalable, robust base structure handling core attributes, health, and dynamic damage calculations across all game characters.
- 💥 **Hitbox/Hurtbox Detection:** Precision collision layers utilizing discrete area nodes to handle damage registration, invincibility frames (i-frames), and directional knockback vectors.
- 🔮 **Modular Ability System:** Dynamic skill management allowing entities to smoothly equip, trigger, and track cooldowns for various projectiles and melee skills.
- 📱 **Mobile-Ready Inputs:** Custom-built virtual mobile joystick system and context-sensitive interaction triggers seamlessly integrated into the gameplay UI canvas.
- 🎛️ **DRY Architecture:** Reusable component-based design patterns keeping velocity, health, and combat code completely modular.

---

## 🛠️ Tech Stack

| Layer          | Technologies                                                                 |
|----------------|------------------------------------------------------------------------------|
| **Game Engine**| Godot Engine v4.x (Core Engine, Physics, Hierarchy Management)               |
| **Language**   | GDScript (Object-Oriented scripts, Signals, Custom Resources)                |
| **Patterns**   | Finite State Machines (FSM), Component-Driven Design, Observer Pattern       |
| **Target**     | PC & Mobile (Cross-platform input translation)                               |

---

## 🚀 Getting Started

### Prerequisites

- [Godot Engine v4.x](https://godotengine.org/download) (Standard version) installed on your machine.
- Git for version control.

### Installation

1. **Clone the repository**
```bash
   git clone [https://github.com/your-username/sentinels-spire.git](https://github.com/your-username/sentinels-spire.git)
   cd sentinels-spire

```

2. **Open the Project in Godot**
* Launch the Godot Project Manager.
* Click **Import**, navigate to the cloned `sentinels-spire` folder, and select the `project.godot` file.
* Click **Import & Edit** to open the workspace.


3. **Run the Project**
* Press `F5` (or the Play button in the top right) to launch the main game scene.
* Switch between keyboard/mouse testing or the on-screen virtual mobile joystick controls.



---

📁 **Project Structure**

```text
sentinels_spire/
├── project.godot          # Godot project configuration file
├── export_presets.cfg     # Platform export configurations (ignored/local)
├── icon.svg               # Default project icon
├── Scenes/                # Instantiated game worlds and UI layers
│   ├── Main.tscn          # Main game loop initializer
│   └── UI/                # Mobile joysticks and HUD scenes
├── Scripts/               # Core backend systems & architecture
│   ├── Components/        # Reusable nodes (HealthComponent, HitboxComponent)
│   ├── State/             # FSM base classes and entity states
│   └── Abilities/         # Projectile data, skill configurations, and casting logic
└── README.md

```

---

## 👥 Contributions

* **Main Developer** – Systems Architect & Gameplay Programmer
*Designed and programmed the backend entity system, engineered the combat/ability frameworks, implemented the Finite State Machines, and built the custom mobile input translation layer.*

> *Note: The main developer focused exclusively on the technical, backend framework; all visual assets, animations, and sprite designs are currently placeholders pending art integration.*

---

## ⚠️ Important Notes

* This project represents the **technical engine architecture** of the game. Visual assets, tilesets, production-ready character sprites, and polished audio tracks are omitted or kept as basic primitives to isolate the engineering logic.
* Local editor metadata folders (like `.godot/` and `.import/`) are automatically excluded via the project's `.gitignore` to keep the codebase lightweight and prevent tracking thousands of temporary binary files.

---

## 📜 License

This project is for educational and portfolio demonstration purposes. The source code and engine architectures are available for review, but game concepts and custom code are not licensed for commercial replication.

---

## 🙏 Acknowledgments

* The Godot Engine community for providing an outstanding, open-source framework for component-driven game development.

---

**Happy developing! ⚔️**

```

```
