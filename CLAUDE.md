# OAuthMagikLink

App macOS **menu bar** (SwiftUI, AppKit) — utilitaire qui nettoie les URLs OAuth cassées (retours à la ligne, espaces, encodage) et les reconstruit proprement.

## Architecture

- **Type** : macOS menu bar app (`.accessory` policy, pas de dock icon)
- **Stack** : Swift 5+ / SwiftUI / AppKit (`NSStatusItem`, `NSPopover`)
- **Target** : macOS uniquement (utilise `NSPasteboard`, `NSWorkspace`, `NSStatusBar`)
- **Entry point** : `OAuthMagikLinkApp.swift` → `AppDelegate` gère le status item + popover
- **UI** : `ContentView.swift` — tout est dans ce fichier (input, parsing, output, actions)

## Conventions

- UI en français (labels, boutons, placeholders)
- SwiftUI avec `@State` pour le state local, pas de ViewModel externe
- Monospaced font (`.monospaced`) pour les URLs et paramètres
- `.ultraThinMaterial` background pour le popover

## Flux principal

1. L'app démarre → se met dans la menu bar (icône `link.circle.fill`)
2. Au clic → popover s'ouvre, auto-paste depuis le clipboard si URL détectée
3. L'utilisateur colle/modifie l'URL brute
4. `cleanURL()` strip newlines/espaces, valide le scheme `http(s)://`
5. Affichage du résultat + inspection des query params via `URLComponents`
6. Actions : copier dans le clipboard / ouvrir dans le browser

## Build & Run

```bash
# Ouvrir dans Xcode :
open OAuthMagikLink.xcodeproj

# Build en CLI :
xcodebuild -project OAuthMagikLink.xcodeproj -scheme OAuthMagikLink -configuration Debug build
```

## Améliorations potentielles (ne pas implémenter sans demande explicite)

- Support d'URL schemes custom (non-http)
- Détection automatique du provider OAuth (Google, Azure AD, GitHub...)
- Historique des URLs nettoyées
- Raccourci clavier global pour ouvrir le popover

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
