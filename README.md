# Omnicosmic-Menu-GDScript
menu for Godot game with GD Script. generator. 

# Godot Main Menu Builder (Tool Script)

This project demonstrates a fully script-driven **main menu generator** for Godot 4.5.1.  
It automatically creates and aligns UI elements such as title images and buttons, directly inside the **Godot editor** using a `@tool` script — meaning you can preview and edit your menu layout live without running the game.

The project is designed to be **minimal yet practical**, serving as a foundation for building your own interactive game menus.

---

## ✨ Features

- Automatically generates a **title image** and **menu buttons** (e.g., *Play Game*, *Editor*, *Options*, *Quit*).
- Allows you to add buttons dynamically from the **Inspector**.
- Auto-centers the menu and scales title graphics based on window size.
- Works both in-editor and at runtime (auto-adjusts for the actual viewport size).
- All generated nodes appear in the **Scene panel** and are saved in your `.tscn` file.
- Includes a debug backdrop option for layout testing.

---

## 📁 Files in this mini project

| File | Purpose |
|------|----------|
| `res://scripts/MenuGen.gd` | The main `@tool` script that builds and updates the menu. |
| `res://assets/fonts/ProggyVector-Regular.ttf` | Example font used by the buttons. |
| `res://assets/screens/uoc-main-title.png` | Example title image for testing layout. |
| `res://main.tscn` | Sample scene used for testing the script. |

---

## ⚙️ Setup Instructions

1. **Open or create a new Godot 4.5.1 project.**
2. Create the folder structure:  
```

res://scripts/
res://assets/fonts/
res://assets/screens/

```
3. Copy the respective files into each folder.
4. In the **Scene panel**, add a root `Node` named `MainNode`.
5. Attach the `MenuGen.gd` script to `MainNode`.
6. Open the **Inspector** and set:
- `Font Path` → your `.ttf` file.
- `Title Image Path` → your title `.png` file.
- Optionally tweak width, height, and center ratio values.
7. Toggle **Rebuild Now** to auto-generate the full layout.
8. Optionally, use **Add Button Text** + **Add Button Now** to add extra buttons.

---

## ▶️ Running the Scene

When you play the scene, the script automatically adapts to the **runtime viewport**, ensuring all elements stay visible and properly scaled regardless of window or DPI settings.

If you don’t see your buttons, enable the `Debug Menu Backdrop` property to confirm positioning.

---

## 🧩 Notes

- The script uses **`@tool`** to let you see the results directly in the editor.
- Every node created by the script is assigned an **owner**, so it’s visible and saved with the scene.
- Intended as a **learning and starter tool** — perfect for experimenting with procedural UI generation in Godot.

---

## 📜 License

This sample code and assets are provided under the **MIT License**.  
You’re free to modify and use it in your own projects, commercial or non-commercial.

Copyright © Michael Ten

The code for Ultra Omnicosmic is released under the MIT License.
However, "Ultra Omnicosmic"™ and its associated logos and branding
are trademarks of Michael Ten.

You are free to use and modify this code, but you may not use the
"Ultra Omnicosmic" name or branding for derivative projects that are
not part of the official Ultra Omnicosmic ecosystem.

---

## 💡 Credits

Developed for demonstration and learning purposes in **Godot 4.5.1**.  
Assets and layout created as part of the **Ultra Omnicosmic** series of experiments.
```


Would you like me to make this slightly more *GitHub-optimized* (with a short tagline under the title, emoji icons in section headers, and collapsible setup steps)? It would make it more readable and eye-catching on your repository’s main page.
