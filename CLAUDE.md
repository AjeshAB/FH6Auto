# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

FH6Auto is a **Windows-only** desktop automation tool for the game Forza Horizon 6 (`forzahorizon6.exe`). It drives the game by taking screenshots, locating UI elements via OpenCV template matching, and injecting keyboard/mouse input. It is not a fixed-coordinate clicker — every action is gated on first recognizing the expected on-screen state, which is the project's core design principle.

The codebase, UI, comments, and runtime logs are written in **Chinese**. Match that language when editing existing strings/comments.

## Commands

- Install deps: `pip install -r requirements.txt`
- Run (dev): `python main.py` — must run on Windows; will not work on this Linux dev box (uses `win32gui`, `ctypes.windll`, targets `forzahorizon6.exe`).
- Build the distributable exe: `build.bat` (Windows) — runs PyInstaller `-F -w --uac-admin`, bundling `images/` and `assets/` and `assets/icon.ico` into a single `dist/FH6Auto.exe`. **`main.py` is the build target.**

There is **no test suite and no linter** configured.

## Architecture

### Single-file monolith
Everything lives in one class, `FH_UltimateBot(ctk.CTk)` in [main.py](main.py) (~3900 lines): UI construction, config I/O, the image-matching engine, game-control logic, and crash recovery. There are no other modules.

[main ocr test.py](main%20ocr%20test.py) is a **near-duplicate experimental variant** that adds OCR text recognition (EasyOCR, see `init_ocr_engine`, `find_text`, `match_ocr_results`, driven by [assets/config/ocr_targets.json](assets/config/ocr_targets.json)). It is NOT built or shipped, and EasyOCR is not in `requirements.txt`. When changing core logic in `main.py`, be aware this file may need the same change mirrored, but treat `main.py` as canonical.

### Resource & path strategy (important)
Two roots, resolved for both dev and PyInstaller-frozen runs:
- `get_app_dir()` → exe dir (frozen) or script dir.
- `get_internal_dir()` → PyInstaller `sys._MEIPASS` (frozen) or app dir.

- **`images/`** (39 PNG templates) are bundled into the exe, then `auto_extract_images()` copies them to an *external* `images/` next to the exe on first run (never overwriting existing files). `get_img_path()` prefers the external copy, falling back to the bundled one — this is deliberate so users can replace templates to adapt to their resolution/quality without rebuilding.
- **`assets/`** is internal/read-only (icon, qrcode, config templates), accessed via `get_asset_path()`.
- **`config.json`** is the user's runtime settings, read/written at `APP_DIR/config.json`. `auto_extract_configs()` migrates older `bot_config.json`/`bot-config.json` names forward.
- Template match results are cached to `cache/template_cache.pkl` + `template_meta.json`, plus in-memory `scaled_template_cache` / `file_template_cache`.

### Image-matching engine
Built on `cv2.matchTemplate` (`TM_CCOEFF_NORMED`); default `MATCH_THRESHOLD = 0.8`. Templates were captured at a **2560px-wide base resolution**; `get_scales_to_try()` computes scales relative to that and tries a prioritized list (≈0.45–1.8) so matching survives other resolutions. There is a large family of finders/waiters — plain, `_gray`, `_transparent`, `_with_element` (anchor + sub-element), `_ultimate_safe` (positive match + anti-pattern guard), plus `_multi`/`_fast`/`_stable` variants. Prefer reusing one of these over writing new matching code.

### Region system
`self.regions` maps Chinese region names (`全界面`, `左上`, `中间`, …) to screen rectangles. It starts as the full screen, then `check_and_focus_game()` rebinds it to the **game window's client rect** so all matching/clicks stay inside the game window. Window targeting works by finding the `forzahorizon6.exe` PID via `tasklist`, locating its HWND, focusing/restoring it, forcing the English IME, and recomputing regions.

### Input injection
Low-level `SendInput` via `ctypes` using DirectInput scan codes (`DIK_CODES`, `KeyBdInput`) for `hw_key_down/up/press` and mouse move/click — this is what works against the game. `pydirectinput` is also used. `stop_all()` force-releases all held keys to avoid "stuck key" states on stop.

### Pipeline orchestration
`start_pipeline(start_step)` runs a 4-stage pipeline on a daemon thread (`runner`):
`steps = ["race", "buy", "cj", "sell"]` → `logic_race`, `logic_buy_car`, `logic_super_wheelspin`, and sell (mode 1 = `find_and_remove_consumable_car`, mode 2 = `sell_consumable_car`).
Each stage is independently enabled (`chk_1..4`) and points to its successor (`next_1..4`, 1-based), forming a configurable loop; `global_loops` caps total iterations. On a stage failure the runner calls `attempt_recovery()` (return to menu, or restart the game) and retries, up to `MAX_RECOVERIES = 10` consecutive failures before hard-stopping.

### Platform-critical startup details
- `check_windows_dependencies()` runs first and warns (via MessageBox) if VC++ runtime DLLs are missing — OpenCV depends on them.
- **DPI awareness is set before importing any UI library** (`SetProcessDpiAwareness(2)`), and customtkinter scaling is forced to 1.0 (`deactivate_automatic_dpi_awareness`). Do not reorder these or coordinates will drift on high-DPI displays.
- F8 is the global emergency-stop hotkey (pynput listener).

## Gotchas

- The app's working directory must contain **no Chinese characters** in the path (logged as a startup warning).
- This is fundamentally Windows software; you can edit and reason about it here on Linux but cannot run or visually verify it.
- `config.json` is committed to the repo and serves as both a default and the live user config.
