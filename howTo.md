# Emacs IDE Configuration

This Emacs configuration provides an IDE-like experience. It is divided into distinct modular files (`mk-*.el`) to separate functionalities. It relies on **Tree-sitter** for syntax highlighting, **Eglot** for Language Server Protocol (LSP) support, and the **Vertico/Consult** ecosystem for completion and navigation.

---

## ⚠️ Major Keybinding Overrides

This configuration intentionally overrides certain default Emacs keybindings to remap specific workflows.

| Action | Keybinding | Replaced Default Emacs Behavior | Source File |
| :--- | :--- | :--- | :--- |
| **Hide Emacs (macOS)** | `M-w` | ⚠️ Previously `kill-ring-save` (Copy text). | `early-init.el` |
| **Avy Jump** | `M-g` | ⚠️ Previously a prefix key (e.g., `M-g M-g` for `goto-line`). | `mk-editing.el` |
| **Project-wide Search** | `M-f` | ⚠️ Previously `forward-word`. | `mk-development.el` |
| **Expand Region** | `C-x e` | Previously `kmacro-end-and-call-macro`. | `mk-development.el` |

*(Note for macOS users: The Right Option key modifier is set to `none` to allow typing native special characters like `[`, `{`, `|`, `\` without triggering Emacs commands).*

---

## 1. Navigation and Search
*Powered by Vertico, Consult, Marginalia, Orderless, and Project.el.*

These packages replace native Emacs completion menus with interactive, fuzzy-search interfaces that display additional context.

### Global Shortcuts (`mk-completion.el` & `mk-development.el`)
| Keybinding | Action | Package / Tool |
| :--- | :--- | :--- |
| `Shift + M-O` | Find a file in the current project | Project |
| `M-f` | Search for text across the entire project (Ripgrep) | Project |
| `Shift + Tab` | Navigate between open buffers | Consult |
| `C-<tab>` | Navigate between buffers tied to the current project | Consult |
| `M-R` | Open a recently closed file | Consult |
| `C-c i` | Toggle the outline menu (code structure) in a side window | Imenu-list |

### Contextual Actions: Embark
**Embark** acts as a keyboard-driven context menu for Emacs.
* **Usage:** Press **`C-.`** (Control + Period) anywhere (on a URL, a file path, a variable name, or an item inside a Vertico search list).
* **Result:** A buffer opens listing all available actions for the target at point (e.g., Rename, Delete, Open in other window, Copy path).

---

## 2. Development and Code Editing
*Powered by Eglot (LSP), Tree-sitter, Company, and Flycheck.*

### Autocompletion and LSP (`mk-code-completion.el`)
When opening a supported file (React, TS, Python, etc.), Eglot connects to the corresponding language server, and Company provides an in-buffer dropdown menu for autocompletion.
* `C-n` / `C-p`: Navigate down/up the suggestion list.
* `Enter` or `Tab`: Accept the selected suggestion.

### Diagnostics and Errors (`mk-development.el`)
Code diagnostics are handled by **Flycheck** and rendered with floating tooltips by **Flyover**.
| Keybinding | Action | 
| :--- | :--- | 
| `M-+` | Toggle the Flycheck error list buffer | 
| `C-c f n` | Jump to the next error/warning | 
| `C-c f p` | Jump to the previous error/warning | 

### Editing Utilities (`mk-editing.el`)
| Keybinding | Action | Package |
| :--- | :--- | :--- |
| `M-g` | **Avy:** Displays target letters on visible lines. Type the letter to jump the cursor to that line, or type a number to trigger standard `goto-line`. | Avy |
| `C-<return>` | **Multiple Cursors (Iedit):** Targets a word and selects all its occurrences in the buffer. Edits apply simultaneously. (Press `C-g` to exit). | Iedit |
| `C-x e` | **Expand Region:** Expands the text selection by semantic increments (word -> inside quotes -> entire block). | Expand-region |
| `C-c r` | Interactive visual search and replace. | Visual-replace |

---

## 3. Git and Version Control
*Powered by Magit and Diff-hl.*

Diff-hl displays indicators in the left margin to highlight added, modified, or deleted lines based on the Git status.

| Keybinding | Action | Purpose |
| :--- | :--- | :--- |
| `C-x g` | Open **Magit Status** | Opens the main Git repository dashboard. |
| `C-c g` | Magit File Dispatch | Opens a menu of Git commands scoped to the current file. |

**Basic Magit Workflow (`C-x g`):**
* `s`: Stage the file under the cursor.
* `u`: Unstage the file under the cursor.
* `c c`: Initiate a commit (type the commit message, then press `C-c C-c` to finalize).
* `P p`: Push commits to the remote repository.
* `F p`: Pull changes from the remote repository.

---

## 4. Interface, Terminal, and Productivity
*Powered by Vterm, Punch-line, and Focus-delight.*

### Terminal (`mk-term.el`)
| Keybinding | Action | Purpose |
| :--- | :--- | :--- |
| `C-c v` | **Toggle Vterm** | Opens or toggles a fully functional terminal emulator window at the bottom of the frame. |
| `Cmd + Left/Right`| Vterm Navigation | Move the cursor to the beginning or the end of the prompt line. |

### Focus and Tasks (`mk-ui.el`)
| Keybinding | Action | Package |
| :--- | :--- | :--- |
| `C-x C-d` | **Focus Mode** | Centers the text, hides UI elements, and dims inactive buffers. | Focus-delight |
| `C-x t n` | Next Task | Displays the next pending task in the mode-line/status bar. | Punch-line |
| `C-x t a` | Show All Tasks | Opens the list of current tasks and history. | Punch-line |

---

## Installation and External Dependencies

This configuration requires specific external tools and fonts installed on the host operating system to render correctly and execute background processes:

1. **Fonts (Required for icons and UI):**
   * A patched Nerd Font (e.g., `Symbols Nerd Font Mono`) for iconography.
   * `Iosevka` and `Iosevka Aile` for monospace and variable-pitch text rendering.
   * Run `M-x nerd-icons-install-fonts` inside Emacs to install the symbol font locally.
2. **System Tools (via Homebrew on macOS or apt/pacman on Linux):**
   * `ripgrep` (Required for project-wide text search).
   * `fd` (Required for fast file indexing).
   * `cmake` and `libtool` (Required to compile the Vterm module).

## About Tree-sitter
This configuration targets Emacs 29+ with built-in Tree-sitter support. Grammars are handled by `treesit-auto` (`mk-development.el`) and are automatically installed upon opening a file of a specific language for the first time. The `emacs-startup-hook` resolves standard language mode conflicts (e.g., forcing `.js` files into `tsx-ts-mode`).