# 🧲 Magnetic Freedom

### A Robotics-Based Stealth Game
**Intra BUET Robo Challenge GameJam 2026**

---

## 🎮 About the Game

**Magnetic Freedom** is a 3D robotics stealth game developed for the **Intra BUET Robo Challenge GameJam 2026**.

You operate the **MagneticFreedom Bot**, a mobile robotic platform equipped with a controllable robotic arm and magnetic end effector.

Valuable components from a secret **BUET Robotics Society research project** have been stolen and are being held inside a restricted industrial facility.

Your mission is to recover the required components and bring them safely to the designated delivery zone.

But the facility is monitored by autonomous security vehicles.

**Get detected for too long, and the mission fails.**

> Recover the research.  
> Avoid detection.  
> Bring Magnetic Freedom home.

---

## 🎯 Gameplay

The game consists of **five increasingly difficult missions**.

In each mission, the player must:

- Navigate the MagneticFreedom Bot through the facility
- Operate its robotic arm
- Control the angular position of the magnetic end effector
- Align the arm's magnet with the magnet attached to the research box
- Carefully position the magnets close enough to establish a magnetic connection
- Retrieve the research components
- Transport the required components to the delivery zone
- Avoid autonomous security vehicles
- Complete the mission before the timer reaches zero

As the missions progress, the challenge increases through **tighter time limits, additional components, and more demanding positioning and recovery tasks**.

---

## 🤖 Robotics & Degrees of Freedom

The MagneticFreedom Bot combines a mobile robotic platform with a controllable robotic arm and magnetic end effector.

The gameplay demonstrates **five primary controllable degrees of freedom (DOF):**

| System | DOF | Movement |
|---|---:|---|
| Mobile Platform | 2 DOF | Forward/Backward and Left/Right |
| Robotic Arm | 2 DOF | Elbow and Forearm movement |
| Magnetic End Effector | 1 DOF | Angular/Rotational movement |

### Total: **5 Primary Controllable DOF**

The magnetic mechanism acts as the end effector, allowing the bot to rotate the magnet, align it with the research component, establish a magnetic connection, and transport the component to the delivery zone.

---

## 🚨 Security System

The facility is monitored by autonomous security vehicles.

When a security vehicle detects the MagneticFreedom Bot, the player has a **2-second escape window** to move outside the detection zone.

If the player remains inside the detection zone until the countdown reaches zero:

**MISSION FAILED**

The security system adds a stealth and timing element to the robotics-based gameplay.

---

## ⏱️ Mission System

There are **5 missions** in total.

Each mission has:

- A limited time
- A required number of research components
- Magnetic recovery objectives
- Autonomous security vehicles
- A designated delivery zone

The difficulty increases as the player progresses through the missions.

---

## 🎮 Controls

### 🚗 Vehicle

| Key | Action |
|---|---|
| `W` | Move Forward |
| `S` | Move Backward |
| `A` | Move Left |
| `D` | Move Right |

### 🦾 Robotic Arm

| Key | Action |
|---|---|
| `Q` / `E` | Elbow Movement |
| `↑` / `↓` | Forearm Movement |

### 🧲 Magnetic System

| Key | Action |
|---|---|
| `M` + `W/A/S/D` | Move Magnetic End Effector |
| `Space` | Attach / Detach |

### ⚙️ System

| Key | Action |
|---|---|
| `ENTER` | Start |
| `ESC` | Pause / Resume |

---

## 📖 Story

Some valuable components have been stolen from the **BUET Robotics Society's secret research project**.

Deep inside a restricted industrial facility, the stolen components are being held by a corporate group determined to stop the research project from reaching the public.

The research was never meant for profit.

**It was being developed to serve society.**

BUET Robotics Society deploys the **MagneticFreedom Bot** to recover the stolen components.

But the facility is under constant surveillance.

> Stay hidden.  
> Recover the components.  
> Avoid detection.  
> Complete all five missions.

---

## 🎬 Gameplay Explanation

A complete gameplay explanation covering the controls, robotic arm operation, magnetic pickup system, mission objectives, and security mechanics is available below.

**Gameplay Explanation Video:**

[Watch the Gameplay Explanation](https://www.youtube.com/watch?v=iZhnd9Jzy8o)

---

## 🛠️ Built With

- **Engine:** Godot 4
- **Programming Language:** GDScript
- **Target Platform:** Windows PC

---

## 📂 Project Structure

```text
Magnetic-Freedom/
│
├── assets/
│   ├── audio/
│   ├── story/
│   └── ...
│
├── scenes/
│   ├── Main.tscn
│   └── ...
│
├── scripts/
│   ├── level_manager.gd
│   ├── story_screen.gd
│   ├── pause_menu.gd
│   ├── hud.gd
│   └── ...
│
├── ui/
│   └── StoryScreen.tscn
│
├── project.godot
└── README.md
