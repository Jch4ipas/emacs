# My Emacs Configuration (Web Development Focused)

This configuration transforms Emacs 30+ into a true modern, fast, and elegant IDE. It leverages the latest built-in Emacs technologies (Tree-sitter, Eglot) for optimal performance without bloating the system.

> **Acknowledgments:** A massive thank you to Konrad. This setup is heavily inspired by and built upon his fantastic Emacs configuration. You can find his original repository here: [Konrad's Emacs Config](https://github.com/konrad1977/emacs).

## Key Features

* **Modern Interface:** Custom welcome dashboard, stylized status bar (`punch-line`), and smooth scrolling (`ultra-scroll`).
* **Intelligent Syntax Engine (Tree-sitter):** Blazing fast and highly accurate syntax highlighting for Web (JS, TS, HTML, CSS), Python, Bash, C++, and more.
* **Autocompletion (Corfu + Eglot):** Modern UI dropdowns powered by local Language Server Protocols (LSP) for real-time code analysis.
* **Integrated Git Ecosystem:** `Magit` for seamless version control, `diff-hl` for live margin highlights, and `git-timemachine`.
* **Native Terminal:** `vterm` integrated directly into Emacs for flawless execution speed.
* **Lightning Fast Search:** Deep integration with `ripgrep`.

---

## Prerequisites (macOS / Linux)

Before installing this configuration, your system must have the basic tools required to compile certain packages (like vterm and Tree-sitter grammars) and run the language servers.

### 1. Compilation & Search Tools
On macOS (via Terminal and Homebrew):
```bash
# Install Apple Developer Tools (C Compiler)
xcode-select --install

# Install Ripgrep (for blazing fast project-wide searches)
brew install ripgrep
```

### 2. Node.js Environment & Language Servers (LSP)
Eglot requires external programs to analyze your code. Install Node.js, then run this command to get the language servers for TypeScript, HTML, CSS, JSON, Python, and Bash:

```bash
npm install -g typescript typescript-language-server vscode-langservers-extracted pyright bash-language-server
```

---

## Installation

1. If you already have an Emacs configuration folder, back it up first:
```bash
mv ~/.emacs.d ~/.emacs.d.backup
```

2. Clone this repository directly in its place:
```bash
git clone [https://github.com/YOUR_NAME/YOUR_REPO.git](https://github.com/YOUR_NAME/YOUR_REPO.git) ~/.emacs.d
```

3. **Launch Emacs.**
   * *Important note for the first boot:* Emacs might appear frozen for 10 to 30 seconds. This is completely normal! It is automatically downloading and compiling all the required packages and Tree-sitter grammars from GitHub in the background. Let it finish. All subsequent startups will be instantaneous.

---

## Quick Keybindings

| Shortcut | Action |
| :--- | :--- |
| `C-c v` | Open a fast terminal (vterm) |
| `M-x magit-status` | Open the Git dashboard |
| `C-x t n` | Next task (Punch-line) |
| `M-x rg` | Launch a global search across the project |