<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0+-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5+-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5+">
  <img src="https://img.shields.io/badge/SwiftUI-000000?style=flat-square&logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="MIT License">
  <a href="https://ko-fi.com/fullya"><img src="https://img.shields.io/badge/Ko--fi-Support-FF5E5B?style=flat-square&logo=ko-fi&logoColor=white" alt="Ko-fi"></a>
  <a href="https://github.com/sponsors/fullya99"><img src="https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?style=flat-square&logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

<h1 align="center">◇ MagikOAuth</h1>

<p align="center">
  <strong>A macOS menu bar utility that cleans broken OAuth URLs and makes them usable again.</strong>
</p>

<p align="center">
  <em>Built with the "Prism / Aurora Dark" design system — dark-first, glass UI, OAuth-aware syntax highlighting.</em>
</p>

---

## The Problem

If you've ever worked with **Claude Code** (or any CLI tool that handles OAuth), you know the pain:

- You switch between accounts, terminals, SSH sessions
- An OAuth callback URL gets split across lines
- Newlines, spaces, and broken encoding sneak into the URL
- You paste it into your browser and... **nothing works**

You end up manually cleaning the URL in a text editor, stripping invisible characters, fixing the encoding — every single time.

**MagikOAuth fixes this in one click.** Copy any broken OAuth URL, and it's instantly cleaned, parsed, and ready to use.

## How It Works

1. **Copy** any OAuth URL (broken or not)
2. **MagikOAuth detects it** automatically — no need to open the app
3. The URL is **cleaned** (newlines, spaces, encoding stripped)
4. **Click the URL** to copy the clean version
5. **Open in browser** with one click

That's it. It lives in your menu bar, out of the way until you need it.

## Install

### Download (recommended)

1. Go to the [**Releases**](../../releases/latest) page
2. Download **`MagikOAuth-1.0.dmg`**
3. Open the DMG
4. Drag **MagikOAuth** into **Applications**
5. Launch from Applications — it appears in your menu bar as `◇`

> **First launch:** macOS may warn that the app is from an unidentified developer.
> Right-click the app → **Open** → click **Open** again. You only need to do this once.

### Build from source

Want to tweak the code, add features, or just see how it works? The project is fully open source.

```bash
# Clone the repo
git clone https://github.com/fullya99/MagikOAuth.git
cd MagikOAuth

# Open in Xcode
open OAuthMagikLink.xcodeproj

# Or build from the command line
xcodebuild -project OAuthMagikLink.xcodeproj -scheme OAuthMagikLink -configuration Debug build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/OAuthMagikLink-*/Build/Products/Debug/MagikOAuth.app`.

**Requirements:** Xcode 15+ and macOS 14.0+ (Sonoma).

## Features

| Feature | Details |
|---|---|
| **Live clipboard monitoring** | Automatically detects OAuth URLs as you copy them |
| **URL cleaning** | Strips newlines, carriage returns, spaces, and fixes encoding |
| **OAuth param inspector** | Syntax-highlighted parameter breakdown by type |
| **Click-to-copy** | Click the cleaned URL to copy it instantly |
| **Global shortcut** | `⌘⇧C` to toggle the panel from anywhere |
| **Dark-first design** | Aurora Dark palette with glass UI components |
| **Dual glass rendering** | Custom glass (macOS 14+) / native Liquid Glass (macOS 26+) |
| **Auto-clear** | Sensitive tokens cleared from memory after 5 minutes |
| **Accessibility** | Full VoiceOver support |

### OAuth Param Syntax Highlighting

MagikOAuth doesn't just clean URLs — it **decomposes them like a prism**:

```
endpoint    https://accounts.google.com/o/oauth2/auth
code        4/0AQlEd8xK...kFgQ          ← violet (secrets)
redirect    https://myapp.com/callback    ← cyan (redirects)
scope       openid email profile          ← amber (permissions)
state       xYz9k2mN...                  ← rose (security)
client_id   123456789.apps.google         ← teal (identifiers)
```

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `⌘⇧C` | Toggle MagikOAuth panel (global) |
| `⌘O` | Open cleaned URL in browser |
| Click on URL | Copy to clipboard |

## Project Structure

```
OAuthMagikLink/
├── OAuthMagikLinkApp.swift      # App entry + status item
├── FloatingPanel.swift          # NSPanel + controller
├── URLViewModel.swift           # @Observable — all business logic
├── ContentView.swift            # Main UI layout
├── ParamsView.swift             # OAuth param inspector
├── AppTheme.swift               # Aurora Dark design system (colors, fonts, spacing)
├── GlassComponents.swift        # Glass UI components (dual macOS 14/26 path)
├── OAuthParamClassifier.swift   # Param key → Aurora color mapping
├── ClipboardManager.swift       # Clipboard read/write/monitor
└── GlobalShortcut.swift         # ⌘⇧C global hotkey
```

### Contributing

1. Fork the repo
2. Create your branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Build & test (`xcodebuild -scheme OAuthMagikLink build`)
5. Commit (`git commit -m 'feat: add my feature'`)
6. Push (`git push origin feature/my-feature`)
7. Open a Pull Request

All contributions are welcome — bug fixes, new features, design improvements.

## Roadmap

- [ ] Configurable global shortcut
- [ ] URL history (last 10 cleaned URLs)
- [ ] OAuth provider auto-detection (Google, Azure AD, GitHub...)
- [ ] Sparkle auto-update
- [ ] Safari/Chrome extension

## Support

If MagikOAuth saves you time, consider supporting the project:

<p>
  <a href="https://ko-fi.com/fullya"><img src="https://img.shields.io/badge/Buy_me_a_coffee-Ko--fi-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white" alt="Ko-fi"></a>
  <a href="https://github.com/sponsors/fullya99"><img src="https://img.shields.io/badge/Sponsor-GitHub_Sponsors-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

## License

MIT — do whatever you want with it.
