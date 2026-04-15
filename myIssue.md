# Emacs Configuration - Troubleshooting & Fixes

This document tracks the technical issues encountered during the setup of this Emacs configuration and the solutions implemented to resolve them.

**Environment Context:** Please note that this configuration is running on **`emacs-plus@30`**, installed via Homebrew on macOS with an M3. All the issues and fixes documented below were specifically experienced and resolved on this version.

## Autocompletion: Transition from Corfu to Company

**Issue:** Choosing between `Corfu` and `Company` for code autocompletion.
**Decision:** Switched to **Company** for the primary autocompletion engine.
**Reason:** While `Corfu` is modern and lightweight, `Company` (Complete Anything) was chosen for its maturity and "out-of-the-box" stability. 
* **Reliability:** Company provides a robust dropdown UI that works consistently across different buffer types without requiring extensive modular setup.
* **Integration:** It integrates seamlessly with `company-prescient` for better candidate ranking based on usage history.
* **Feature Set:** Company includes many built-in backends and handling logic that often requires separate packages in the Corfu ecosystem.
* **Source:** Configured in `mk-code-completion.el`.

## Themes & UI (`vscode-dark-plus-theme`, `display-line-numbers`)

**Issue:** Window transparency (translucency) was lost whenever the "Dark Modern" (VS Code) theme was loaded.
**Solution:** Loading a theme overrides default frame parameters. The transparency must be reapplied *after* the theme is active.
* **File:** `mk-theme.el`
* **Fix:** Added `(modify-all-frames-parameters '((alpha-background . 85)))` within the `:config` block of the theme.

**Issue:** Line numbers displayed relative distances (1, 2, 3 up/down) instead of absolute line numbers.
**Solution:** Disabled relative line numbering, which is typically intended for Vim-style navigation.
* **File:** `mk-development.el`
* **Fix:** In the `prog-mode` configuration, changed `(display-line-numbers-type 'relative)` to `(display-line-numbers-type t)`.

## Icons & Typography (`nerd-icons`)

**Issue:** Applying a global text font string caused file icons to appear as empty boxes.
**Solution:** Using a strict global font string like `:font "Menlo-14"` overrides symbol fonts. The font must be set by family and height separately.
* **File:** `init.el`
* **Fix:** Replaced the font definition with: `(set-face-attribute 'default nil :family "Menlo" :height 140)`.

**Issue:** Nerd Icons were missing entirely from the UI.
**Solution:** The physical font files were not installed on the operating system.
* **Manual Action:** Executed `M-x nerd-icons-install-fonts` within Emacs and confirmed installation in the macOS "Font Book" app.

**Issue:** ⚠️ Specific icons (e.g., weather clouds) or emojis appeared as Chinese characters (e.g., 埏) on macOS.
**Solution:** A conflict between the Unicode Private Use Area (PUA) used by Nerd Fonts and the macOS fallback font (PingFang SC).
* **File:** `init.el`
* **Fix:** Explicitly mapped the hexadecimal PUA ranges to the correct symbol font:
  `(set-fontset-font t '(#xe000 . #xf8ff) "Symbols Nerd Font Mono")`
  `(set-fontset-font t '(#xf0000 . #xf1af0) "Symbols Nerd Font Mono")`

## Syntax Highlighting (`treesit`, `treesit-auto`)

**Issue:** Syntax highlighting in JS/TS files would break completely when encountering HTML tags (JSX/TSX).
**Solution:** The default Regex-based parser does not support embedded JSX syntax. Tree-sitter is required for accurate parsing.
* **File:** `mk-development.el`
* **Fix:** Integrated the `treesit-auto` package to automatically download and activate TSX grammars.

**Issue:** Upon restarting Emacs, `.js` and `.tsx` files defaulted to `typescript-ts-mode` (which lacks HTML support) instead of `tsx-ts-mode`.
**Solution:** Other packages were overriding `auto-mode-alist` during the startup sequence.
* **File:** `mk-development.el`
* **Fix:** Implemented an `emacs-startup-hook` to delete incorrect associations and force `.js`, `.jsx`, and `.tsx` extensions to point to `tsx-ts-mode` at the very end of the startup process.

## Navigation (`avy`)

**Issue:** ⚠️ Error: `Cannot open load file: No such file or directory, avy` when attempting a line jump (`M-g M-g`).
**Solution:** The local installation of the `avy` package was missing or corrupted.
* **Manual Action:** Executed `M-x package-reinstall`, selected `avy`, and forced a clean download.

**Issue:** The shortcut `M-g M-g` prompted for a character search instead of a line number.
**Solution:** The keybinding was assigned to Avy's character search command instead of line search.
* **File:** `mk-editing.el`
* **Fix:** Rebound `M-g` and `M-g M-g` to `avy-goto-line`. (Note: `avy-goto-line` automatically switches to standard `goto-line` if a number is typed).