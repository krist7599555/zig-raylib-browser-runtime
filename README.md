# 🎮 Zig + Raylib Browser Runtime ✨

> **Making Zig dance in the browser with WebAssembly magic!** 🪄

![Screenshot](https://github.com/user-attachments/assets/dd71b28d-de73-4f80-8fcf-8fdbe018ef64)


[![GitHub](https://img.shields.io/badge/GitHub-krist7599555%2Fzig--raylib--browser--runtime-blue?logo=github)](https://github.com/krist7599555/zig-raylib-browser-runtime)
[![Demo](https://img.shields.io/badge/🎪_Live_Demo-GitHub_Pages-success)](https://krist7599555.github.io/zig-raylib-browser-runtime/)

---

## 🌟 What's This?

This is a **minimal working example** of running [Zig](https://ziglang.org/) + [Raylib](https://www.raylib.com/) in your web browser using **Emscripten**! 🎉

Getting `build.zig` to work with WebAssembly was... *challenging* 😅. So I made this minimal config to help you (and future me) get started without the headaches!

---

## 🚀 Quick Start

```bash
# Build the project
zig build

# Open index.html in your browser
# Or use a local server:
python3 -m http.server 8000
# Then visit: http://localhost:8000
```

---

## 🔍 What to Look At

Here are the **key files** that make the magic happen:

### 📄 **`index.html`**
The entry point! This is where:
- 🎨 The canvas lives
- 🔌 JavaScript loads the WebAssembly module
- 🎮 The game loop runs via `requestAnimationFrame`
- 💬 JavaScript ↔ Zig communication happens (string passing, function calls)

**Cool stuff inside:**
- Loads `game.mjs` (the compiled Emscripten module)
- Calls exported Zig functions like `_game_init()`, `_game_update()`
- Demonstrates string passing between JS and Zig! 🎯

---

### ⚙️ **`build.zig`**
The **build configuration** that was hard to get right! 🛠️

**Key highlights:**
```zig
// Target WebAssembly with Emscripten
.cpu_arch = .wasm32,
.os_tag = .emscripten,

// Use emcc to link everything together
emcc_linker.addArgs(&.{"-o", "zig-out/lib/game.mjs"});
emcc_linker.addFileArg(lib_main.getEmittedBin());
emcc_linker.addFileArg(lib_raylib.getEmittedBin());
```

**Important parts:**
- 🎯 Sets up Emscripten target
- 📦 Links Zig code + Raylib into `.wasm` + `.mjs`
- 🔧 Configures WebGL2 and GLFW
- 📤 Exports functions for JavaScript to call
- 🧰 Exports runtime methods for string handling

**Pro tip:** This is the minimal config that actually works! 💪

---

### 🎨 **`src/main.zig`**
The Zig code that runs in the browser! 🦎

**What it does:**
- 🎮 Initializes Raylib with `game_init()`
- 🔄 Updates every frame with `game_update()`
- 🎨 Renders 3D graphics (cubes, capsules, grid)
- 📷 Handles camera controls (orbital & first-person modes)
- 💬 Communicates with JavaScript (title getter/setter)
- 🪵 Logs to browser console using `emscripten_log()`

**Exported functions:**
```zig
export fn game_init() void
export fn game_update() void
export fn game_set_title(in: [*:0]const u8) void
export fn game_get_title(out: [*:0]u8) void
export fn game_log_info() void
```

These are called from JavaScript! 🌉

---

## 🎯 The Problem This Solves

**The Challenge:** Getting `build.zig` to properly compile Zig + Raylib for the web browser is *not trivial*! 😰

Common issues:
- ❌ Linking errors with Emscripten
- ❌ Missing WebGL/GLFW configuration
- ❌ Function export confusion
- ❌ String passing between JS ↔ Zig
- ❌ Build graph dependencies

**The Solution:** This repo provides a **minimal, working configuration** that you can use as a starting point! 🎊

---

## 🛠️ How It Works

```
┌─────────────┐
│  src/*.zig  │  Your Zig code
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  build.zig  │  Compiles to .a (static library)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    emcc     │  Links .a files → .wasm + .mjs
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ index.html  │  Loads and runs in browser! 🎉
└─────────────┘
```

---

## 🎪 Features

- ✅ 3D rendering with Raylib
- ✅ Camera controls (orbital & first-person)
- ✅ Interactive UI with raygui
- ✅ JavaScript ↔ Zig communication
- ✅ String passing examples
- ✅ Console logging from Zig
- ✅ Minimal build configuration

---

## 📚 Learn More

- 🦎 [Zig Language](https://ziglang.org/)
- 🎮 [Raylib](https://www.raylib.com/)
- 🌐 [Emscripten](https://emscripten.org/)
- 📦 [raylib-zig](https://github.com/Not-Nik/raylib-zig)

---

## 💖 Contributing

Found a better way to configure `build.zig`? Have improvements? PRs welcome! 🎉

---

## 📜 License

MIT (or whatever makes you happy! 😊)

---

<div align="center">

**Made with 💙 and lots of ☕**

*Now go build something awesome in the browser with Zig!* 🚀

</div>
