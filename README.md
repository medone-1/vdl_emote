# **VDL Emote Menu – RedM**

A lightweight and modern **NUI animation & emote menu** for **RedM**, featuring smooth navigation, keyboard support, categories, scenarios, walkstyles, and interactive animations.

---

## 📌 **Features**

* ✔️ Clean and responsive NUI menu
* ✔️ Multiple categories: Animations, Scenarios, Emotes, Clothes, Walk Styles, Interactive Animations
* ✔️ Smooth keyboard navigation (Up/Down/Enter/Backspace)
* ✔️ Fully customizable via `config.lua`
* ✔️ Supports opening by keybind or command
* ✔️ Cancel animation function
* ✔️ Lightweight & optimized

---

## 🧩 **Installation**

1. Download or clone the resource.
2. Place it inside your RedM `resources` folder.
3. Add this to your `server.cfg`:

```
ensure vdl_emotes
```

4. Restart your server.

---

## ⚙️ **Configuration (config.lua)**

```lua
Config = {
    OpenKey       = 0x3C0A40F2,  -- Keybind to open the menu
    OpenCommand   = "vdl",       -- Optional command
    UseCommand    = false,       -- Enable command usage instead of keybind
    CommandName   = "emote"      -- Command used if UseCommand = true
}
```

---

## 🎮 **Controls**

| Action           | Key            |
| ---------------- | -------------- |
| Open Menu        | Configurable   |
| Navigate Up      | ↑ Arrow        |
| Navigate Down    | ↓ Arrow        |
| Select           | Enter          |
| Back             | Backspace      |
| Cancel Animation | From main menu |

---

## 🖥️ **UI Files**

| File         | Purpose                        |
| ------------ | ------------------------------ |
| `index.html` | Main interface structure       |
| `style.css`  | Visual styling                 |
| `script.js`  | Menu logic & NUI communication |

---

## 📂 **Folder Structure**

```
vdl_emotes/
│
├── client/
│   └── main.lua
│
├── data/
│   └── *.lua
│
├── html/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
├── config.lua
└── fxmanifest.lua
```

---

## 🧡 **Author**

**Developer:** Jelali
**Platform:** RedM / Cfx.re

---

## 📜 **License – MIT**

```
MIT License

Copyright (c) 2025 Jelali

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```