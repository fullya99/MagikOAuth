# MagikOAuth

App macOS **menu bar** (SwiftUI, AppKit) — utilitaire qui nettoie les URLs OAuth cassées (retours à la ligne, espaces, encodage) et les reconstruit proprement. Direction artistique **"Prism / Aurora Dark"**.

## Architecture

- **Type** : macOS menu bar app (`.accessory` policy, pas de dock icon)
- **Stack** : Swift 5+ / SwiftUI / AppKit (`MenuBarExtra`, `NSPanel`, `NSStatusItem`)
- **Target** : macOS 14.0+ (Sonoma)
- **Design** : "Prism / Aurora Dark" — dark-first, glass custom + Liquid Glass (macOS 26+)
- **Entry point** : `OAuthMagikLinkApp.swift` → `AppDelegate` + `FloatingPanelController`
- **State** : `URLViewModel` (@Observable) — owned by `FloatingPanelController`

## Fichiers

| Fichier | Rôle |
|---------|------|
| `OAuthMagikLinkApp.swift` | App entry + AppDelegate + status item |
| `FloatingPanel.swift` | NSPanel subclass + FloatingPanelController |
| `URLViewModel.swift` | @Observable — toute la logique métier |
| `ContentView.swift` | Layout principal (header, input, output, actions) |
| `ParamsView.swift` | Inspection params OAuth syntax-highlighted |
| `AppTheme.swift` | Design system Aurora Dark (couleurs, fonts, spacings) |
| `GlassComponents.swift` | GlassModifier + GlassCard + GlassButton (dual path macOS 14/26) |
| `OAuthParamClassifier.swift` | Mapping param OAuth → couleur Aurora |
| `ClipboardManager.swift` | NSPasteboard wrapper (protocol-based, testable) |
| `GlobalShortcut.swift` | Raccourci global ⌘⇧C via NSEvent monitor |

## Conventions

- UI en français (labels, boutons, placeholders)
- Dark-first design, `preferredColorScheme(.dark)`
- `@Observable` ViewModel, pas de `@State` pour la logique
- SF Mono pour URLs/params, SF Pro Rounded pour le titre
- Glass dual path : `@available(macOS 26, *)` dans `GlassModifier`
- Protocol-based utilities pour testabilité (`ClipboardManaging`)

## Flux principal

1. L'app démarre → icône `diamond.fill` dans la menu bar
2. Clic ou `⌘⇧C` → FloatingPanel s'ouvre, auto-paste si URL détectée et champ vide
3. L'utilisateur colle/modifie l'URL brute (bouton "Coller" explicite aussi)
4. `URLViewModel.cleanURL()` strip newlines/espaces, valide scheme, retourne error state si invalide
5. Affichage résultat dans GlassCard + toggle inspection params (syntax-highlighted par type OAuth)
6. Actions : copier `⌘C` / ouvrir `⌘O` / ♡ donation Ko-fi
7. Panel close → timer 5min → clear state automatique

## Build & Run

```bash
# Ouvrir dans Xcode :
open OAuthMagikLink.xcodeproj

# Build en CLI :
xcodebuild -project OAuthMagikLink.xcodeproj -scheme OAuthMagikLink -configuration Debug build
```

## Performance

- Cible : <5MB RAM idle, 0% CPU idle, <50ms ouverture panel
- Pas de timer/polling en background
- Clipboard lu on-demand (ouverture panel uniquement)
- Parsing temps réel, debounce resize panel seulement

---

<!-- claude-ops:gstack:start -->
## gstack

Ce projet utilise **gstack** — un framework de skills Claude Code pour des workflows de développement rigoureux.

---

### Orchestration — Comment travailler dans ce projet

Avant de proposer quoi que ce soit, **toujours évaluer le contexte git** :

```bash
git branch --show-current
git status --short
git log main..HEAD --oneline
```

Puis choisir le bon workflow selon cette table :

| Branch | Status | Commits vs main | Workflow |
|--------|--------|-----------------|----------|
| `main` | clean | 0 | **Plan Only** : `/plan-ceo-review` → `/plan-eng-review` |
| `feature/*` | clean | 0 | **Full Feature Cycle** : `/full-cycle` |
| `feature/*` | dirty ou commits | N≥1 | **Quick Ship** : `/review` → `/ship` |
| any | — | deploy/staging évoqué | **Post-Deploy** : `/qa` (+ `/setup-browser-cookies` si auth) |
| any | — | retro/sprint évoqué | **Retro** : `/retro` |

**Toujours expliquer le choix** :
> "Tu es sur `feature/x` avec 3 commits prêts. Je suggère Quick Ship : `/review` puis `/ship`. On continue ?"

---

### Règles de séquençage (invariantes)

1. `/plan-ceo-review` **AVANT** `/plan-eng-review` — la vision produit façonne l'exécution technique
2. `/review` **AVANT** `/ship` — **jamais shipper sans review**, même sous pression
3. `/setup-browser-cookies` **AVANT** `/qa` — si les pages testées sont authentifiées
4. **Bloquer sur les issues CRITICAL** — une review bloquante empêche le ship, point final
5. **Expliquer avant chaque invocation** de skill (ce qu'il va faire + pourquoi)
6. **Résumer après chaque step** (ce qui s'est passé, prochaine étape)

---

### Skills

| Skill | Quand l'utiliser |
|-------|-----------------|
| `/plan-ceo-review` | Challenger le problème, trouver le produit 10x, élargir la vision |
| `/plan-eng-review` | Verrouiller l'architecture, data flow, edge cases, plan de tests |
| `/review` | Analyser le diff vs main avant tout push — SQL safety, trust boundaries, side effects |
| `/ship` | Merge main + tests + version bump + changelog + push + PR |
| `/browse` | Naviguer, cliquer, screenshot dans un vrai browser headless |
| `/qa` | Test pass complet avec health score et rapport structuré |
| `/setup-browser-cookies` | Importer les cookies du browser réel pour tester des pages auth |
| `/retro` | Rétrospective avec métriques, tendances, breakdown par contributeur |

### Commandes (workflows pré-chainés)

| Commande | Séquence | Cas d'usage |
|----------|----------|-------------|
| `/full-cycle` | Plan CEO → Plan Eng → PAUSE → Review → Ship → QA | Feature nouvelle de zéro |
| `/deploy` | Ship → QA | Feature codée, prête à déployer |
| `/health-check` | Diagnostic complet de l'installation gstack | Debug / vérification |

---

### Règles browser

- Toujours utiliser `/browse` pour naviguer sur le web, jamais les outils `mcp__claude-in-chrome__*`
- Si un skill ne fonctionne pas : `cd .claude/skills/gstack && ./setup`
<!-- claude-ops:gstack:end -->
