# MagikOAuth — TODOs

## P2 — Historique des URLs nettoyées
**What:** Stocker les 10 dernières URLs nettoyées, accessibles via un menu déroulant dans le header.
**Why:** L'utilisateur nettoie souvent des URLs en rafale (debug OAuth flow). Revenir sur une URL précédente sans recoller est un gain de temps majeur.
**Context:** Le ViewModel a la structure pour accueillir un `[String]`. Persistence via UserDefaults chiffré (`kSecAttrAccessible`). Le header a l'espace pour un bouton history.
**Effort:** M
**Depends on:** v1 stable.

## P3 — Détection automatique du provider OAuth
**What:** Identifier le provider OAuth (Google, Azure AD, GitHub, Auth0, Okta...) à partir du hostname et afficher un badge.
**Why:** Contexte immédiat pour l'utilisateur — "c'est un flow Google" — sans lire l'URL.
**Context:** Le hostname est déjà parsé via `URLComponents.host`. Table de mapping pour les 10 providers majeurs. Phase 2 de la roadmap.
**Effort:** S
**Depends on:** v1 stable.
