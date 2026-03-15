---
name: health-check
description: Verify gstack installation — checks browse binary, Chromium, all skill symlinks, Bun version, and OS capabilities.
allowed-tools:
  - Bash
  - Read
  - Glob
---

Run a comprehensive health check of the gstack installation. Check each component and report PASS or FAIL.

## Checks to perform

Run these checks and report results in a table:

### 1. OS Detection
```bash
uname -s
```
Report: macOS / Linux / WSL / Unknown

### 2. Bun Version
```bash
bun --version
```
PASS if bun is installed, FAIL otherwise. Report version.

### 3. Browse Binary
```bash
test -x ~/.claude/skills/gstack/browse/dist/browse && echo "OK" || echo "MISSING"
```
PASS if executable exists.

### 4. Chromium (Playwright)
```bash
cd ~/.claude/skills/gstack && bun --eval 'import { chromium } from "playwright"; const b = await chromium.launch(); await b.close(); console.log("OK");'
```
PASS if Chromium launches successfully.

### 5. Skill Symlinks
Check that these 8 symlinks exist in `~/.claude/skills/`:
- browse, plan-ceo-review, plan-eng-review, review, ship, qa, setup-browser-cookies, retro

```bash
for skill in browse plan-ceo-review plan-eng-review review ship qa setup-browser-cookies retro; do
  if [ -L "$HOME/.claude/skills/$skill" ]; then
    echo "PASS $skill"
  else
    echo "FAIL $skill"
  fi
done
```

### 6. Plugin Manifest
```bash
test -f ~/.claude/skills/gstack/.claude-plugin/plugin.json && echo "OK" || echo "MISSING"
```

### 7. Display Server (for cookie import)
On macOS: always available.
On Linux: check `$DISPLAY` or `$WAYLAND_DISPLAY`.
Report capability status.

## Output Format

```
gstack Health Check
═══════════════════
OS:              macOS (Darwin)           ✓
Bun:             1.x.x                    ✓
Browse binary:   PASS                     ✓
Chromium:        PASS                     ✓
Skills (8/8):    All linked               ✓
Plugin manifest: PASS                     ✓
Display server:  Available                ✓

Overall: 7/7 PASS
```

If any check fails, add a "Suggestions" section with specific fix commands.
