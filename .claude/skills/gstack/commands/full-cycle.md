---
name: full-cycle
description: |
  Complete feature development cycle: plan-ceo-review → plan-eng-review → pause for implementation →
  review → ship → QA. Use for end-to-end feature development from ideation to deployment verification.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Skill
  - AskUserQuestion
---

Execute the full feature development cycle. This is a multi-phase workflow with a pause for implementation.

## Phase 1: Planning

### Step 1: CEO Review
Invoke `/plan-ceo-review` to challenge premises, expand scope, and find the 10-star product vision.

Use the Skill tool:
```
skill: "plan-ceo-review"
```

Summarize the CEO review output: key decisions, scope changes, vision alignment.

### Step 2: Eng Review
Invoke `/plan-eng-review` to lock in architecture, data flow, edge cases, and test coverage.

Use the Skill tool:
```
skill: "plan-eng-review"
```

Summarize: architecture decisions, key data flows, identified edge cases, test plan.

## Phase 2: Implementation Pause

After both reviews complete, inform the user:

"Planning complete! Here's the summary:
- **CEO Review**: [key points]
- **Eng Review**: [key points]

Now it's time to implement. When you're done coding and ready to proceed with review and shipping, say **'continue cycle'** or invoke `/full-cycle` again."

**STOP HERE.** Do not proceed until the user explicitly says to continue.

## Phase 3: Review & Ship

### Step 3: Code Review
Invoke `/review` to analyze the diff against main.

Use the Skill tool:
```
skill: "review"
```

If critical issues are found, inform the user and **do not proceed to ship**. Ask them to fix the issues first.

### Step 4: Ship
Only if review passes without critical issues, invoke `/ship`.

Use the Skill tool:
```
skill: "ship"
```

Summarize: PR URL, version, changelog entry.

## Phase 4: Verification

### Step 5: QA
Ask the user for the staging URL:

"PR created! Provide the staging URL to run QA verification, or say 'skip' to finish."

If URL provided, invoke `/qa`:
```
skill: "qa"
args: "<staging-url>"
```

### Final Report
Provide a complete cycle summary:
- **Plan**: Key decisions from CEO + Eng reviews
- **Review**: Issues found and resolution
- **Ship**: PR URL, version
- **QA**: Health score (if run)
- **Overall Status**: COMPLETE or NEEDS ATTENTION
