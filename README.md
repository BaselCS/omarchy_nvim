# ⚡ Neovim Flutter & Development Setup

Full-featured Neovim environment tailored for **Flutter, Dart, Python, and Full-Stack Development** with 100% VS Code parity (Tap-to-Jump, Gutter Icons, Image Previews, Auto-Const on Save, and Runtime Problem Modals).

---

## 🎯 Flutter Development Keybindings (`<leader>F`)

| Shortcut | Description | Action / Details |
|---|---|---|
| `<leader>Fs` | **Flutter Run (Start)** | Launches app on connected device/emulator (`<F5>` also works) |
| `<leader>Fr` | **Hot Reload** | Instantly reloads UI state |
| `<leader>FR` | **Hot Restart** | Full app state restart |
| `<leader>Fq` | **Flutter Quit** | Stops running debug session |
| `<leader>Fd` | **Select Device** | Switch target (Android Emulator, Linux Desktop, Phone) |
| `<leader>Fe` | **Emulators** | List and launch Android AVDs |
| `<leader>Fi` | **Tap-to-Inspect Mode** | Toggle on-device inspect: **Tap any widget on phone to jump to code!** |
| `<leader>Fo` | **Widget Tree Outline** | Opens interactive sidebar widget hierarchy |
| `<leader>Ft` | **Open DevTools** | Launches Google Flutter DevTools in Zen browser |
| `<leader>Fl` | **Toggle Dev Log** | Opens live console logs & framework output |
| `<leader>Fp` | **Flutter Pub Get** | Fetch dependencies |
| `<leader>FP` | **Flutter Pub Upgrade** | Upgrade dependencies |
| `<leader>Fa` | **Search & Add Package** | Live fuzzy-search `pub.dev` and install dependency |
| `<leader>FA` | **Search & Add Dev Package** | Live fuzzy-search `pub.dev` and install dev dependency |
| `<leader>Ff` | **Dart Fix (File)** | Auto-add all `const`, remove redundant `Container`s in current file |
| `<leader>FF` | **Dart Fix (Project)** | Auto-fix all lints across entire project |
| `<leader>Fw` | **Quick Widget Actions** | Wrap with `Widget`, `Column`, `Row`, `Padding`, `Center`, or Remove Widget |
| `<leader>Fv` | **Preview Image Asset** | Opens floating graphic preview for image path under cursor |

---

## 🖼️ Icons & Image Previews

| Shortcut | Description | Action |
|---|---|---|
| `<leader>uI` | **Toggle Icons & Images** | Turn on/off Gutter and Inline Material/Cupertino Icons & Image thumbnails |
| `<leader>Fv` | **Floating Image View** | Preview `.png`, `.jpg`, `.svg`, `.webp` in rounded Ghostty popup |
| `<leader>uC` | **Toggle Color Highlights** | Toggle inline color swatches (`#hex`, `Colors.blue`) |

* **Gutter Sign Column:** Material Icons (`󰐕 ` next to line 93) and Image thumbnails (`  `) show directly in the line numbers column.
* **Inline Previews:** Glyphs appear directly in code next to `Icons.<name>` and image asset strings.

---

## 🚨 Runtime Errors & Problem Detection

| Trigger | Description | Behavior |
|---|---|---|
| **App Exception / Crash** | **Floating Error Modal** | Pops up automatically on red screen/crashes with stack trace & hint. Press `<Enter>` to jump to failing line. |
| **Cursor on Error Line** | **Problem Details Popup** | Pausing cursor on any syntax/type error automatically shows rounded description box. |
| **`K` / `<leader>cd`** | **Manual Problem Hover** | Inspect error explanation under cursor. |
| **`]d` / `[d`** | **Next / Prev Problem** | Jump between diagnostics in file. |
| **`<leader>xx`** | **Project Diagnostics** | Full searchable list of all errors in project via Trouble. |
| **`<leader>xX`** | **Buffer Diagnostics** | All errors in current buffer. |

---

## 🛠️ Code Editing & LSP Navigation

| Shortcut | Description |
|---|---|
| `gd` | **Go to Definition** |
| `gr` | **Go to References** |
| `gI` | **Go to Implementation** |
| `<leader>ca` | **Code Action / Quick Fix** |
| `<leader>cr` | **Rename Symbol** (Project-wide) |
| `<leader>cf` | **Format Document** |
| `:w` (Save) | **Auto-Const & Organize Imports** (Auto-fixes const keywords on save) |

---

## 🐞 DAP Debugger Controls

| Key | Action |
|---|---|
| `<F5>` | Start / Continue Debugging |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<F12>` | Step Out |
| `<leader>db` | Toggle Breakpoint on line |
| `<leader>du` | Toggle DAP UI (Scopes, Call Stack, Watches, Breakpoints) |
| `<leader>dr` | Open DAP REPL Console |

---

## 📁 General LazyVim Navigation

| Shortcut | Description |
|---|---|
| `<leader><space>` | Find Files (Fuzzy search) |
| `<leader>/` | Grep (Search across project text) |
| `<leader>e` | File Explorer (Neo-tree) |
| `<leader>bd` | Close Buffer |
| `<leader>qq` | Quit Neovim |
