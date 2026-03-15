# gstack

**gstack turns Claude Code from one generic assistant into a team of specialists you can summon on demand.**

Eight opinionated workflow skills + an orchestration layer for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Plan review, code review, one-command shipping, browser automation, QA testing, engineering retrospectives — all as slash commands. Plus an orchestrator that chains them into automated workflows.

### Without gstack

- The agent takes your request literally — it never asks if you're building the right thing
- It will implement exactly what you said, even when the real product is something bigger
- "Review my PR" gives inconsistent depth every time
- "Ship this" turns into a long back-and-forth about what to do
- The agent can write code but can't see your app — it's half blind
- You still do QA by hand: open browser, click around, check pages, squint at layouts

### With gstack

| Skill | Mode | What it does |
|-------|------|--------------|
| `/plan-ceo-review` | Founder / CEO | Rethink the problem. Find the 10-star product hiding inside the request. |
| `/plan-eng-review` | Eng manager / tech lead | Lock in architecture, data flow, diagrams, edge cases, and tests. |
| `/review` | Paranoid staff engineer | Find the bugs that pass CI but blow up in production. Not a style nitpick pass. |
| `/ship` | Release engineer | Sync main, run tests, push, open PR. For a ready branch, not for deciding what to build. |
| `/browse` | QA engineer | Give the agent eyes. It logs in, clicks through your app, takes screenshots, catches breakage. Full QA pass in 60 seconds. |
| `/qa` | QA lead | Systematic QA testing with structured reports, health scores, screenshots, and regression tracking. Three modes: full, quick, regression. |
| `/setup-browser-cookies` | Session manager | Import cookies from your real browser (Comet, Chrome, Arc, Brave, Edge) into the headless session. Test authenticated pages without logging in manually. |
| `/retro` | Engineering manager | Team-aware retro: your deep-dive + per-person praise and growth opportunities for every contributor. |

## Demo: one feature, five modes

I start almost every feature in plan mode. I describe what I want to build, then use `/plan-ceo-review` to pressure-test whether I am even building the right thing. Only after the product direction is locked do I shift into engineering, review, ship, and test.

```
You:   [enter plan mode, describe the feature]
       I want to add seller photo upload to the listing app. Sellers
       should be able to upload a photo of their item and we create
       the listing from it.

You:   /plan-ceo-review

Claude: "Photo upload" is not the feature. The real job is helping sellers
        create listings that actually sell. Here's what the 10-star version
        looks like: auto-identify the product from the photo, pull specs and
        pricing comps from the web, draft the title and description, suggest
        the best hero image...

You:   /plan-eng-review

Claude: [Architecture diagram, state machine for upload → classify → enrich
        → draft pipeline, async job boundaries, failure modes, test matrix]

You:   [exit plan mode, implement the plan]

You:   /review

Claude: Race condition: two tabs can overwrite cover-photo selection.
        Trust boundary: pulling web data into draft generation creates
        a prompt injection vector. Missing: orphan cleanup for failed uploads.

You:   (fix the issues)

You:   /ship

Claude: [Syncs main, runs tests, pushes branch, opens PR — 6 tool calls, done]

You:   /setup-browser-cookies staging.myapp.com

Claude: Imported 8 cookies for staging.myapp.com from Chrome.

You:   /qa https://staging.myapp.com --quick

Claude: [Smoke test: homepage + 5 pages, 30 seconds]
        Health Score: 91/100. No critical issues. 1 medium: mobile nav overlap.

You:   /browse staging.myapp.com/listings/new — test the upload flow specifically

Claude: [22 tool calls — navigates routes, fills the upload form, verifies
        enrichment renders, checks console for errors, screenshots each step]
        Listing flow works end to end on staging.
```

## Who this is for

You already use Claude Code heavily and want consistent, high-rigor workflows instead of one mushy generic mode. You want to tell the model what kind of brain to use right now — founder taste, engineering rigor, paranoid review, or fast execution.

This is not a prompt pack for beginners. It is an operating system for people who ship.

## How to fly: 10 sessions at once

gstack is powerful with one Claude Code session. It is transformative with ten.

[Conductor](https://conductor.build) runs multiple Claude Code sessions in parallel — each in its own isolated workspace. That means you can have one session running `/qa` on staging, another doing `/review` on a PR, a third implementing a feature, and seven more working on other branches. All at the same time.

gstack is Conductor-aware out of the box. Each workspace gets its own isolated browser instance (separate Chromium process, cookies, tabs, and logs) so `/browse` and `/qa` sessions never collide. No configuration needed — it just works.

This is the setup I use. One person, ten parallel agents, each with the right cognitive mode for its task. That is not incremental improvement. That is a different way of building software.

## Orchestrator: automated multi-skill workflows

gstack includes an orchestration layer that chains skills into complete workflows. Instead of invoking skills one by one, let the orchestrator handle the sequence.

### Workflow commands

| Command | What it does |
|---------|-------------|
| `/full-cycle` | Plan (CEO → Eng) → pause for implementation → review → ship → QA. End-to-end feature cycle. |
| `/deploy` | Ship + QA verify. For branches ready to land. |
| `/health-check` | Verify gstack installation: binary, Chromium, skills, OS. |

### Orchestrator agent

Ask naturally — "orchestrate this feature", "plan and ship", "run the full workflow" — and the orchestrator agent picks the right workflow based on your git context:

- **On `main`, no changes** → suggests feature branch, offers Plan Only
- **Feature branch, no commits** → Full Feature Cycle
- **Feature branch with commits** → Quick Ship (review → ship)
- **Mentions deployment** → Post-Deploy Verify

### Cross-platform support

| Feature | macOS | Linux Desktop | Linux VPS | WSL |
|---------|-------|---------------|-----------|-----|
| Browse binary | OK | OK | OK | OK |
| Chromium headless | OK | OK | OK | OK |
| Cookie import (browser) | OK | — | — | — |
| Cookie import (JSON) | OK | OK | OK | OK |
| System deps | auto | install-deps | install-deps | install-deps |

---

## Install

**Requirements:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Git](https://git-scm.com/), [Bun](https://bun.sh/) v1.0+. `/browse` compiles a native binary — works on macOS and Linux (x64 and arm64).

### Quick install (universal — works on macOS, Linux, WSL)

```bash
curl -fsSL https://raw.githubusercontent.com/fullya99/gstack/main/setup-orchestrator | bash
```

Or clone and run locally:

```bash
git clone https://github.com/fullya99/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup-orchestrator
```

This handles everything: Bun, Git, Chromium, skill registration, plugin registration, and verification. Safe to re-run (idempotent).

### Manual install

### Step 1: Install on your machine

Open Claude Code and paste this. Claude will do the rest.

> Install gstack: run `git clone https://github.com/fullya99/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup` then add a "gstack" section to CLAUDE.md that says to use the /browse skill from gstack for all web browsing, never use mcp\_\_claude-in-chrome\_\_\* tools, and lists the available skills: /plan-ceo-review, /plan-eng-review, /review, /ship, /browse, /qa, /setup-browser-cookies, /retro. Then ask the user if they also want to add gstack to the current project so teammates get it.

### Step 2: Add to your repo so teammates get it (optional)

> Add gstack to this project: run `cp -Rf ~/.claude/skills/gstack .claude/skills/gstack && rm -rf .claude/skills/gstack/.git && cd .claude/skills/gstack && ./setup` then add a "gstack" section to this project's CLAUDE.md that says to use the /browse skill from gstack for all web browsing, never use mcp\_\_claude-in-chrome\_\_\* tools, lists the available skills: /plan-ceo-review, /plan-eng-review, /review, /ship, /browse, /qa, /setup-browser-cookies, /retro, and tells Claude that if gstack skills aren't working, run `cd .claude/skills/gstack && ./setup` to build the binary and register skills.

Real files get committed to your repo (not a submodule), so `git clone` just works. The binary and node\_modules are gitignored — teammates just need to run `cd .claude/skills/gstack && ./setup` once to build (or `/browse` handles it automatically on first use).

### What gets installed

- Skill files (Markdown prompts) in `~/.claude/skills/gstack/` (or `.claude/skills/gstack/` for project installs)
- Symlinks at `~/.claude/skills/browse`, `~/.claude/skills/qa`, `~/.claude/skills/review`, etc. pointing into the gstack directory
- Browser binary at `browse/dist/browse` (~58MB, gitignored)
- `node_modules/` (gitignored)
- `/retro` saves JSON snapshots to `.context/retros/` in your project for trend tracking

Everything lives inside `.claude/`. Nothing touches your PATH or runs in the background.

---

## How it works

Originally created by [Garry Tan](https://x.com/garrytan). Fork with orchestration layer by Arthur Chenais.

I built gstack because I do not want AI coding tools stuck in one mushy mode.

Planning is not review. Review is not shipping. Founder taste is not engineering rigor. If you blur all of that together, you usually get a mediocre blend of all four.

I want explicit gears.

These skills let me tell the model what kind of brain I want right now. I can switch cognitive modes on demand — founder, eng manager, paranoid reviewer, release machine. That is the unlock.

---

## Prompt Cookbook

Optimized prompts to copy-paste into Claude Code. Each one is designed to trigger the right skill or workflow with maximum context.

### Installation prompts

**First install (paste into Claude Code on a new machine):**

> Install gstack with the orchestrator: run `git clone https://github.com/fullya99/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup-orchestrator`. Then add a "gstack" section to CLAUDE.md that lists all available skills (/plan-ceo-review, /plan-eng-review, /review, /ship, /browse, /qa, /setup-browser-cookies, /retro) and workflow commands (/full-cycle, /deploy, /health-check). Say to always use /browse for web browsing, never mcp\_\_chrome tools. Ask if I also want gstack in the current project.

**Install on a headless Linux VPS (no browser UI, SSH only):**

> Install gstack for headless use: run `git clone https://github.com/fullya99/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup-orchestrator`. Note: this is a headless server, skip cookie-import-browser features. After install, run /health-check to verify everything works.

**Update to latest version:**

> Update gstack: run `cd ~/.claude/skills/gstack && git fetch origin && git reset --hard origin/main && ./setup-orchestrator`

**Verify installation:**

> /health-check

---

### Orchestrator trigger prompts

These prompts trigger the orchestrator agent, which auto-detects your git context and chains the right skills.

**Full feature from scratch (you have an idea, no code yet):**

> Orchestrate a new feature: I want to build [describe feature]. Start from planning and take me through the full cycle.

> Plan and ship: I need [feature]. Challenge my assumptions first, then lock the architecture, I'll implement, and we review+ship.

**Ship an existing branch (code is written, needs review + PR):**

> Orchestrate shipping this branch. Review the diff, fix anything critical, then ship it.

> This feature is ready. Run the full review and ship workflow.

**Post-deploy verification (PR is merged, need to check staging):**

> Orchestrate a deployment check on https://staging.myapp.com — import my cookies if needed and run QA.

> Verify this deployment: https://staging.myapp.com. Check all the pages I changed in the last PR.

**End of sprint retro:**

> Run a retrospective for this week. Show me what shipped, who did what, and where we can improve.

---

### Skill-by-skill optimized prompts

#### `/plan-ceo-review` — Founder mode

```
/plan-ceo-review

I want to add [feature]. But before we build anything, challenge whether
this is even the right feature. What's the 10-star version? What job is
the user actually trying to do? Think like a founder, not a ticket-taker.
```

```
/plan-ceo-review

We have a basic CRUD for [entity]. Users can create, read, update, delete.
But it feels like a dead form from 2007. What would make this feel magical?
What are we missing that would make users actually love this?
```

```
/plan-ceo-review SCOPE EXPANSION

Here's our current plan: [paste plan]. I want you to dream bigger.
What's the version of this that makes competitors irrelevant?
Don't be polite — be ambitious.
```

#### `/plan-eng-review` — Eng manager mode

```
/plan-eng-review

The product direction is locked: [summary from CEO review].
Now nail the technical plan. I want architecture diagrams, data flow,
state transitions, failure modes, and a test matrix. Make it buildable.
```

```
/plan-eng-review

We're adding [feature] to [stack: Next.js + Postgres + Redis].
Walk me through: what changes where, what's sync vs async, what can fail,
what needs migration, what needs an index. Give me the diagram.
```

#### `/review` — Paranoid staff engineer mode

```
/review

This branch is green on CI. I need you to find what CI missed.
Look for: N+1 queries, race conditions, trust boundary violations,
missing error handling, stale reads, broken invariants. No style nits.
Only things that could page someone at 3am.
```

```
/review

Focus on security. This branch handles [user input / file upload / payment /
external API data]. What can an attacker do? What's the worst-case scenario
we haven't tested?
```

#### `/ship` — Release engineer mode

```
/ship

Branch is reviewed and ready. Sync with main, run tests, bump version,
update CHANGELOG, commit, push, open PR. No more discussion — land it.
```

#### `/browse` — QA engineer with eyes

```
/browse https://staging.myapp.com — log in with test@example.com / password123,
then navigate to /dashboard, /settings, and /billing. Screenshot each page.
Check console for errors. Report anything broken.
```

```
/browse https://myapp.com/signup — fill the signup form with garbage data
and try to submit. Then fill it correctly and verify the redirect.
Screenshot each step.
```

```
/browse https://docs.stripe.com/api/charges — read this documentation page
and summarize the charge creation API. I need the required params and an example.
```

#### `/qa` — Systematic QA

```
/qa https://staging.myapp.com

Full QA pass. Test every reachable page, fill forms, click buttons,
check responsive layouts, look for console errors. Give me the health
score and a ranked list of issues with screenshots.
```

```
/qa https://staging.myapp.com --quick

30-second smoke test. Does it load? Console errors? Broken nav?
Just tell me if the deploy is healthy.
```

```
/qa https://staging.myapp.com --regression baseline.json

Compare against last week's baseline. What's fixed? What's new?
What's the score delta?
```

#### `/setup-browser-cookies` — Session import

```
/setup-browser-cookies

Open the cookie picker. I need to import sessions for myapp.com
and github.com so I can QA authenticated pages.
```

```
/setup-browser-cookies staging.myapp.com

Import cookies for staging directly — no picker UI needed.
```

#### `/retro` — Engineering retrospective

```
/retro

Run the full retro. Show my commits, LOC, test ratio, shipping streak.
Break down each contributor. Be candid about growth areas.
```

```
/retro compare

Compare this week vs last week. What improved? What regressed?
```

---

### Workflow command prompts

#### `/full-cycle` — Idea to production

```
/full-cycle

I want to build a notification system. Users should get real-time
notifications in-app and email digests daily. Start from CEO review.
```

After the planning pause, when implementation is done:

```
Continue the cycle — I've implemented the notification system.
Review my code and ship it.
```

#### `/deploy` — Ship + verify

```
/deploy

Ship this branch and then QA the staging deployment at
https://staging.myapp.com. Focus on the pages I changed.
```

#### `/health-check` — Installation verification

```
/health-check

Check everything: browse binary, Chromium, all 8 skill symlinks,
Bun version, plugin manifest. Tell me what's broken and how to fix it.
```

---

### Real-world use cases

#### Use case 1: SaaS feature — billing page redesign

```
Session 1 (planning):
  You:    I want to redesign our billing page. Right now it's just a table
          of invoices. Make it better.
  You:    /plan-ceo-review
  Claude: [Rethinks: billing page should reduce churn, not just show invoices.
          Suggests: usage visualization, plan comparison, upgrade nudges,
          payment method management, invoice search]
  You:    /plan-eng-review
  Claude: [Architecture: React components, Stripe API integration, webhook
          handler for payment events, migration for usage_snapshots table]

Session 2 (after implementation):
  You:    /review
  Claude: [Finds: webhook handler doesn't verify Stripe signature,
          usage query has N+1, no rate limit on plan-change endpoint]
  You:    (fix issues)
  You:    /deploy
  Claude: [Ships PR #47, asks for staging URL, runs /qa --quick]
          Health Score: 94/100. All clear.
```

#### Use case 2: Bug fix — urgent production issue

```
  You:    Users report checkout fails on mobile Safari. Fix it.
  Claude: [Investigates, finds CSS Grid issue + missing polyfill]
  You:    /review
  Claude: [Confirms fix is safe, no side effects on desktop]
  You:    /ship
  Claude: [Syncs main, tests green, pushes, opens PR]
  You:    /qa https://staging.myapp.com/checkout --quick
  Claude: [Tests checkout on mobile viewport, confirms fix works]
```

#### Use case 3: Documentation review — read competitor docs

```
  You:    /browse https://competitor.com/docs/api — read their API docs
          and compare with ours. What do they have that we don't?
  Claude: [Navigates 8 pages, screenshots, builds comparison table]
          They have: webhooks, batch endpoints, rate limit headers.
          We're missing: batch endpoints and webhook retry config.
```

#### Use case 4: Multi-environment deployment check

```
  You:    Just deployed v2.4 to all regions. QA each one:
  You:    /qa https://us.myapp.com --quick
  You:    /qa https://eu.myapp.com --quick
  You:    /qa https://ap.myapp.com --quick
  Claude: [Runs 3 smoke tests, reports per-region health scores]
          US: 96/100, EU: 91/100 (slow asset loading), AP: 88/100 (CDN miss on fonts)
```

#### Use case 5: Friday retro + next week planning

```
  You:    /retro
  Claude: [Full week analysis: 52 commits, 4.1k LOC, 3 contributors]
          Biggest ship: billing redesign. Test ratio dropped to 28%.
          Alice crushed it on API work. Bob is blocked on infra.
  You:    Based on that retro, what should we prioritize next week?
  Claude: [Suggests: test coverage sprint, unblock Bob on infra,
          Alice should own the webhook system since she's in the zone]
```

#### Use case 6: Onboarding a new team member

```
  You:    New dev joining Monday. Set up a QA baseline they can use.
  You:    /qa https://staging.myapp.com
  Claude: [Full QA pass, saves baseline to .gstack/qa-reports/baseline.json]
          Health Score: 78/100. 12 known issues documented with screenshots.
  You:    Good. They'll run /qa --regression baseline.json after each PR.
```

---

## `/plan-ceo-review`

This is my **founder mode**.

This is where I want the model to think with taste, ambition, user empathy, and a long time horizon. I do not want it taking the request literally. I want it asking a more important question first:

**What is this product actually for?**

I think of this as **Brian Chesky mode**.

The point is not to implement the obvious ticket. The point is to rethink the problem from the user's point of view and find the version that feels inevitable, delightful, and maybe even a little magical.

### Example

Say I am building a Craigslist-style listing app and I say:

> "Let sellers upload a photo for their item."

A weak assistant will add a file picker and save an image.

That is not the real product.

In `/plan-ceo-review`, I want the model to ask whether "photo upload" is even the feature. Maybe the real feature is helping someone create a listing that actually sells.

If that is the real job, the whole plan changes.

Now the model should ask:

* Can we identify the product from the photo?
* Can we infer the SKU or model number?
* Can we search the web and draft the title and description automatically?
* Can we pull specs, category, and pricing comps?
* Can we suggest which photo will convert best as the hero image?
* Can we detect when the uploaded photo is ugly, dark, cluttered, or low-trust?
* Can we make the experience feel premium instead of like a dead form from 2007?

That is what `/plan-ceo-review` does for me.

It does not just ask, "how do I add this feature?"
It asks, **"what is the 10-star product hiding inside this request?"**

That is a very different kind of power.

---

## `/plan-eng-review`

This is my **eng manager mode**.

Once the product direction is right, I want a different kind of intelligence entirely. I do not want more sprawling ideation. I do not want more "wouldn't it be cool if." I want the model to become my best technical lead.

This mode should nail:

* architecture
* system boundaries
* data flow
* state transitions
* failure modes
* edge cases
* trust boundaries
* test coverage

And one surprisingly big unlock for me: **diagrams**.

LLMs get way more complete when you force them to draw the system. Sequence diagrams, state diagrams, component diagrams, data-flow diagrams, even test matrices. Diagrams force hidden assumptions into the open. They make hand-wavy planning much harder.

So `/plan-eng-review` is where I want the model to build the technical spine that can carry the product vision.

### Example

Take the same listing app example.

Let's say `/plan-ceo-review` already did its job. We decided the real feature is not just photo upload. It is a smart listing flow that:

* uploads photos
* identifies the product
* enriches the listing from the web
* drafts a strong title and description
* suggests the best hero image

Now `/plan-eng-review` takes over.

Now I want the model to answer questions like:

* What is the architecture for upload, classification, enrichment, and draft generation?
* Which steps happen synchronously, and which go to background jobs?
* Where are the boundaries between app server, object storage, vision model, search/enrichment APIs, and the listing database?
* What happens if upload succeeds but enrichment fails?
* What happens if product identification is low-confidence?
* How do retries work?
* How do we prevent duplicate jobs?
* What gets persisted when, and what can be safely recomputed?

And this is where I want diagrams — architecture diagrams, state models, data-flow diagrams, test matrices. Diagrams force hidden assumptions into the open. They make hand-wavy planning much harder.

That is `/plan-eng-review`.

Not "make the idea smaller."
**Make the idea buildable.**

---

## `/review`

This is my **paranoid staff engineer mode**.

Passing tests do not mean the branch is safe.

`/review` exists because there is a whole class of bugs that can survive CI and still punch you in the face in production. This mode is not about dreaming bigger. It is not about making the plan prettier. It is about asking:

**What can still break?**

This is a structural audit, not a style nitpick pass. I want the model to look for things like:

* N+1 queries
* stale reads
* race conditions
* bad trust boundaries
* missing indexes
* escaping bugs
* broken invariants
* bad retry logic
* tests that pass while missing the real failure mode

### Example

Suppose the smart listing flow is implemented and the tests are green.

`/review` should still ask:

* Did I introduce an N+1 query when rendering listing photos or draft suggestions?
* Am I trusting client-provided file metadata instead of validating the actual file?
* Can two tabs race and overwrite cover-photo selection or item details?
* Do failed uploads leave orphaned files in storage forever?
* Can the "exactly one hero image" rule break under concurrency?
* If enrichment APIs partially fail, do I degrade gracefully or save garbage?
* Did I accidentally create a prompt injection or trust-boundary problem by pulling web data into draft generation?

That is the point of `/review`.

I do not want flattery here.
I want the model imagining the production incident before it happens.

---

## `/ship`

This is my **release machine mode**.

Once I have decided what to build, nailed the technical plan, and run a serious review, I do not want more talking. I want execution.

`/ship` is for the final mile. It is for a ready branch, not for deciding what to build.

This is where the model should stop behaving like a brainstorm partner and start behaving like a disciplined release engineer: sync with main, run the right tests, make sure the branch state is sane, update changelog or versioning if the repo expects it, push, and create or update the PR.

Momentum matters here.

A lot of branches die when the interesting work is done and only the boring release work is left. Humans procrastinate that part. AI should not.

### Example

Suppose the smart listing flow is finished.

The product thinking is done.
The architecture is done.
The review pass is done.
Now the branch just needs to get landed.

That is what `/ship` is for.

It takes care of the repetitive release hygiene so I do not bleed energy on:

* syncing with main
* rerunning tests
* checking for weird branch state
* updating changelog/version metadata
* pushing the branch
* opening or updating the PR

At this point I do not want more ideation.
I want the plane landed.

---

## `/browse`

This is my **QA engineer mode**.

`/browse` is the skill that closes the loop. Before it, the agent could think and code but was still half blind. It had to guess about UI state, auth flows, redirects, console errors, empty states, and broken layouts. Now it can just go look.

That is a real step-change. The full cycle becomes: plan, code, run the app, inspect the UI, reproduce the bug, verify the fix, ship. QA stops being "go click around manually" and becomes part of the same agentic loop. It gives the agent eyes. Now it can do the boring, high-context QA work itself: click through the app, catch breakage, verify the fix, and keep going. That feels like having a real operator in the machine.

It is a compiled binary that talks to a persistent Chromium daemon — built on [Playwright](https://playwright.dev/) by Microsoft. First call starts the browser (~3s). Every call after that: ~100-200ms. The browser stays running between commands, so cookies, tabs, and localStorage carry over.

After I push a branch, I tell Claude to go check staging. It does the entire QA pass for me:

```
You:   /browse staging.myapp.com — log in, test the signup flow, and check
       every page I changed in this branch

Claude: [18 tool calls, ~60 seconds]

        > browse goto https://staging.myapp.com/signup
        > browse snapshot -i
        > browse fill @e2 "test@example.com"
        > browse fill @e3 "password123"
        > browse click @e5                    (Submit)
        > browse screenshot /tmp/signup.png
        > Read /tmp/signup.png

        Signup works. Redirected to onboarding. Now checking changed pages.

        > browse goto https://staging.myapp.com/dashboard
        > browse screenshot /tmp/dashboard.png
        > Read /tmp/dashboard.png
        > browse console

        Dashboard loads. No console errors. Charts render with sample data.

        > browse goto https://staging.myapp.com/settings/billing
        > browse screenshot /tmp/billing.png
        > Read /tmp/billing.png

        Billing page loads. Plan selector shows Free/Pro/Enterprise.
        Stripe elements render correctly.

        > browse goto https://staging.myapp.com/api/health
        > browse text

        API health endpoint returns {"status":"ok","version":"2.4.1"}.

        All 4 pages load correctly. No console errors. No broken layouts.
        Signup → onboarding → dashboard flow works end to end.
```

18 tool calls, about a minute. It signed up a test user, navigated every page I changed, took screenshots, read them, checked the console for errors, and verified the API. That is a full QA pass. I did not open a browser.

It works for reading documentation, verifying deployments, filling out forms, taking screenshots, comparing pages across environments, and anything else where Claude needs eyes on a live URL.

**Security note:** `/browse` runs a persistent Chromium session. Cookies, localStorage, and session state carry over between commands. Do not use it against sensitive production environments unless you intend to — it is a real browser with real state. The session auto-shuts down after 30 minutes of idle time.

For the full command reference, technical internals, and architecture details, see [BROWSER.md](BROWSER.md).

---

## `/qa`

This is my **QA lead mode**.

`/browse` gives the agent eyes. `/qa` gives it a testing methodology.

Where `/browse` is a single command — go here, click this, screenshot that — `/qa` is a full systematic test pass. It explores every reachable page, fills forms, clicks buttons, checks console errors, tests responsive layouts, and produces a structured report with a health score, screenshots as evidence, and ranked issues with repro steps.

Three modes:

- **Full** (default) — systematic exploration of the entire app. 5-15 minutes depending on app size. Documents 5-10 well-evidenced issues.
- **Quick** (`--quick`) — 30-second smoke test. Homepage + top 5 nav targets. Loads? Console errors? Broken links?
- **Regression** (`--regression baseline.json`) — run full mode, then diff against a previous baseline. Which issues are fixed? Which are new? What's the score delta?

```
You:   /qa https://staging.myapp.com

Claude: [Explores 12 pages, fills 3 forms, tests 2 flows]

        QA Report: staging.myapp.com — Health Score: 72/100

        Top 3 Issues:
        1. CRITICAL: Checkout form submits with empty required fields
        2. HIGH: Mobile nav menu doesn't close after selecting an item
        3. MEDIUM: Dashboard chart overlaps sidebar below 1024px

        [Full report with screenshots saved to .gstack/qa-reports/]
```

Reports and screenshots accumulate in `.gstack/qa-reports/` so you can track quality over time and compare runs.

**Testing authenticated pages:** Use `/setup-browser-cookies` first to import your real browser sessions, then `/qa` can test pages behind login.

---

## `/setup-browser-cookies`

This is my **session manager mode**.

Before `/qa` or `/browse` can test authenticated pages, they need cookies. Instead of manually logging in through the headless browser every time, `/setup-browser-cookies` imports your real sessions directly from your daily browser.

It auto-detects installed Chromium browsers (Comet, Chrome, Arc, Brave, Edge), decrypts cookies via the macOS Keychain, and loads them into the Playwright session. An interactive picker UI lets you choose exactly which domains to import — no cookie values are ever displayed.

```
You:   /setup-browser-cookies

Claude: Cookie picker opened — select the domains you want to import
        in your browser, then tell me when you're done.

        [You pick github.com, myapp.com in the browser UI]

You:    done

Claude: Imported 2 domains (47 cookies). Session is ready.
```

Or skip the UI entirely:

```
You:   /setup-browser-cookies github.com

Claude: Imported 12 cookies for github.com from Comet.
```

First import per browser triggers a macOS Keychain prompt — click "Allow" or "Always Allow."

---

## `/retro`

This is my **engineering manager mode**.

At the end of the week I want to know what actually happened. Not vibes — data. `/retro` analyzes commit history, work patterns, and shipping velocity and writes a candid retrospective.

It is team-aware. It identifies who is running the command, gives you the deepest treatment on your own work, then breaks down every contributor with specific praise and growth opportunities — the kind of feedback you would actually give in a 1:1. It computes metrics like commits, LOC, test ratio, PR sizes, and fix ratio. It detects coding sessions from commit timestamps, finds hotspot files, tracks shipping streaks, and identifies the biggest ship of the week.

```
You:   /retro

Claude: Week of Mar 1: 47 commits (3 contributors), 3.2k LOC, 38% tests, 12 PRs, peak: 10pm | Streak: 47d

        ## Your Week
        32 commits, +2.4k LOC, 41% tests. Peak hours: 9-11pm.
        Biggest ship: cookie import system (browser decryption + picker UI).
        What you did well: shipped a complete feature with encryption, UI, and
        18 unit tests in one focused push...

        ## Team Breakdown

        ### Alice
        12 commits focused on app/services/. Every PR under 200 LOC — disciplined.
        Opportunity: test ratio at 12% — worth investing before payment gets more complex.

        ### Bob
        3 commits — fixed the N+1 query on dashboard. Small but high-impact.
        Opportunity: only 1 active day this week — check if blocked on anything.

        [Top 3 team wins, 3 things to improve, 3 habits for next week]
```

It saves a JSON snapshot to `.context/retros/` so the next run can show trends. Run `/retro compare` to see this week vs last week side by side.

---

## Troubleshooting

**Skill not showing up in Claude Code?**
Run `cd ~/.claude/skills/gstack && ./setup` (or `cd .claude/skills/gstack && ./setup` for project installs). This rebuilds symlinks so Claude can discover the skills.

**`/browse` fails or binary not found?**
Run `cd ~/.claude/skills/gstack && bun install && bun run build`. This compiles the browser binary. Requires Bun v1.0+.

**Project copy is stale?**
Re-copy from global: `for s in browse plan-ceo-review plan-eng-review review ship retro qa setup-browser-cookies; do rm -f .claude/skills/$s; done && rm -rf .claude/skills/gstack && cp -Rf ~/.claude/skills/gstack .claude/skills/gstack && rm -rf .claude/skills/gstack/.git && cd .claude/skills/gstack && ./setup`

**`bun` not installed?**
Install it: `curl -fsSL https://bun.sh/install | bash`

## Upgrading

Paste this into Claude Code:

> Update gstack: run `cd ~/.claude/skills/gstack && git fetch origin && git reset --hard origin/main && ./setup`. If this project also has gstack at .claude/skills/gstack, update it too: run `for s in browse plan-ceo-review plan-eng-review review ship retro qa setup-browser-cookies; do rm -f .claude/skills/$s; done && rm -rf .claude/skills/gstack && cp -Rf ~/.claude/skills/gstack .claude/skills/gstack && rm -rf .claude/skills/gstack/.git && cd .claude/skills/gstack && ./setup`

The `setup` script rebuilds the browser binary and re-symlinks skills. It takes a few seconds.

## Uninstalling

Paste this into Claude Code:

> Uninstall gstack: remove the skill symlinks by running `for s in browse plan-ceo-review plan-eng-review review ship retro qa setup-browser-cookies; do rm -f ~/.claude/skills/$s; done` then run `rm -rf ~/.claude/skills/gstack` and remove the gstack section from CLAUDE.md. If this project also has gstack at .claude/skills/gstack, remove it by running `for s in browse plan-ceo-review plan-eng-review review ship retro qa setup-browser-cookies; do rm -f .claude/skills/$s; done && rm -rf .claude/skills/gstack` and remove the gstack section from the project CLAUDE.md too.

## Development

See [BROWSER.md](BROWSER.md) for the full development guide, architecture, and command reference.

## License

MIT
