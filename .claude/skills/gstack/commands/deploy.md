---
name: deploy
description: |
  Deploy workflow: run /ship to create a PR, then verify the deployment with /qa.
  Use when ready to ship and verify a feature.
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

Execute a deploy workflow that ships code and verifies the deployment.

## Steps

### Step 1: Ship
Invoke the `/ship` skill to merge main, run tests, review the diff, bump version, update changelog, commit, push, and create a PR.

Use the Skill tool:
```
skill: "ship"
```

After ship completes, summarize: PR URL, version bump, any warnings.

### Step 2: Get Staging URL
Ask the user for the staging/preview URL where the deployment can be verified:

"Ship complete! Please provide the staging or preview URL to verify the deployment. If you want to skip QA verification, say 'skip'."

If the user says "skip", end the workflow with the ship summary.

### Step 3: QA Verify
Invoke the `/qa` skill in quick mode on the provided URL.

Use the Skill tool:
```
skill: "qa"
args: "--quick <staging-url>"
```

### Step 4: Report
Provide a final summary:
- PR URL from ship step
- Health score from QA
- Any issues found
- Overall deploy status: SUCCESS or NEEDS ATTENTION
