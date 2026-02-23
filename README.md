👥 Development Team  
[Dracolardex](https://github.com/Dracolardex)  
[Diaz003](https://github.com/Diaz003)  
[Racara07](https://github.com/Racara07) 

# DefendRush

DefendRush is a 2D pixel‑art **serious game** about basic cybersecurity for everyday users.  
You play on a simulated desktop OS and must keep the system safe by reacting to common digital threats.

---

## Concept

- Educational game, not ethical hacking.
- Core focus: **phishing, spoofing, malware, trojans, password theft, ransomware**.
- All interactions happen inside a fake PC desktop built with **Godot Control nodes**.

---

## Gameplay Overview

During a short “PC session” the player:

- Receives random events: suspicious emails, login alerts, CPU spikes, ransomware pop‑ups.
- Uses desktop apps to respond:
  - **Email**, **Browser**, **Antivirus**, **Backups**, **Settings**, **Privileges Manager**, **Logs**.
- Gains score and keeps a **Security bar** up when making good decisions.
- Loses security and score when letting threats succeed.

End of session:

- Final score.
- Blocked vs successful attacks.
- A few tips based on the player’s mistakes.

---

## Core Features

- Simulated desktop:
  - Pixel‑art wallpaper, app icons, taskbar.
- Mini‑games per threat type (email checks, scans, password creation, backups, etc.).
- HUD with:
  - Security / health bar.
  - Timer for the PC session.
  - Score.

---

## Tech

- Engine: **Godot 4 (2D)**  
- UI: fully made with **Control** nodes (Panel, Button, Label, TextureButton, Containers).  
- Main scenes:
  - `menu.tscn`: room + PC + intro camera zoom.
  - `Screen.tscn`: desktop OS simulation.

---

## Assets (Main Packs Used)

- App icons: `reffpixels – Pixel Art App Icons`
- Retro windows / GUI: `NullTale – Windows XP Asset Pack`, `Comp3Interactive – Retro Windows GUI`
- Cyberpunk UI elements: `Free GUI for Cyberpunk Pixel Art`
- Monospace font for logs/terminal: `NotJam Mono Clean 13`

(See licenses on each itch.io page; we only use free/copyright‑friendly assets.)

---
