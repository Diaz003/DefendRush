## Development Team

* https://github.com/Dracolardex
* https://github.com/Diaz003
* https://github.com/Racara07

---

# DefendRush

**DefendRush** is a 2D pixel-art serious game that teaches basic cybersecurity awareness for everyday users.
You play inside a simulated desktop operating system and must react correctly to digital threats to keep your system safe.

---

## Concept

* Educational game focused on learning security best practices — not offensive ethical hacking.
* Players face threats such as:

  * Phishing
  * Spoofing
  * Malware
  * Trojans
  * Password theft
  * Ransomware
* All gameplay happens inside a desktop simulation built using Godot Control nodes.

---

## Gameplay Overview

During a short “PC session”:

* You receive random security events such as suspicious emails, login alerts, CPU spikes, or ransomware pop-ups.
* You must respond using desktop applications:

  * Email
  * Browser
  * Antivirus
  * Backups
  * Settings
  * Privileges Manager
  * Logs
* Good decisions increase your score and maintain your Security bar.
* Bad decisions reduce your score and system security.

### End of Session Results

* Final score
* Blocked vs successful attacks
* Personalized tips based on your mistakes

---

## Core Features

* Simulated Desktop

  * Pixel-art wallpaper, icons, and taskbar resembling a real OS.
* Threat Mini-Games

  * Small gameplay challenges tied to each attack type (email inspection, scans, password creation, backups, etc.).
* HUD

  * Security bar
  * Session timer
  * Score
* Ready-to-Run Project

  * Scenes prepared to be opened directly in Godot.

---

## Tech

* Engine: Godot 4 (2D)
* UI: Built entirely using Control nodes:

  * Panel
  * Button
  * Label
  * TextureButton
  * Containers

### Main Scenes

* `menu.tscn` — Intro scene with room + PC camera zoom.
* `Screen.tscn` — Desktop simulation where gameplay happens.

---

## Assets (Main Packs Used)

* App icons — reffpixels: Pixel Art App Icons
* Retro GUI — NullTale: Windows XP Asset Pack
* Retro GUI — Comp3Interactive: Retro Windows GUI
* Cyberpunk UI — Free GUI for Cyberpunk Pixel Art
* Monospace font — NotJam Mono Clean 13

(See each asset page for licenses. Only free or copyright-friendly assets are used.)

---

## Repository Structure

```
assets/
scenes/
 ├── menu.tscn
 ├── Screen.tscn
.gitignore
.editorconfig
project.godot
icon.png
README.md
```

Main logic is implemented through Godot scenes and GDScript scripts handling events and UI behavior.

---

## About

DefendRush is an open-source serious game designed to teach users how to recognize and respond to common digital threats through an interactive desktop simulation.
The project is written entirely in GDScript within the Godot engine structure.

---

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/Diaz003/DefendRush.git
   ```
2. Open the project in Godot 4.
3. Run the main scene and start playing.

---

## Purpose

The goal of DefendRush is to make cybersecurity awareness accessible, interactive, and engaging, helping players build real-world digital safety skills while playing.

---
