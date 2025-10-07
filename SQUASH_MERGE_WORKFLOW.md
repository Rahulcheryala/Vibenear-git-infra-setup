# Squash Merge Workflow Guide

## Overview

This repository uses a **squash merge strategy** for promoting changes from `staging` to `main`. This document explains how the commit analysis works and what practices to follow.

## The Challenge with Squash Merges

When you squash merge from `staging` to `main`:
1. Multiple commits in `staging` become a single commit in `main`
2. The individual commits still exist in `staging`'s history
3. Standard git commands can't easily identify which commits were already promoted

### Example Scenario

```
staging:  A → B → C → D → E → F
                        ↓ (squash merge)
main:                   X
```

After squash merge:
- Commits A, B, C were squashed into commit X on `main`
- Commits A, B, C still exist in `staging`'s history
- New commits D, E, F need to be promoted next

The problem: How do we know that A, B, C are already in `main` and only D, E, F are new?

## Our Solution: Sync Point Tracking

We track synchronization points by merging `main` back into `staging` after each promotion:

```
staging:  A → B → C → D → E → F
                  ↓ (squash)
main:             X
                  ↓ (merge back)
staging:  A → B → C → M → D → E → F
                      ↑
                  Sync point
```

The merge commit `M` marks the point where `staging` was last synchronized with `main`.

## Workflow Pattern

### 1. Promote Staging to Main (Squash Merge)

1. Run the production release workflow
2. Review the PR showing commits to promote
3. **Important:** Use "Squash and merge" when merging the PR
4. A single commit is created on `main` containing all changes

### 2. Sync Main Back to Staging (Regular Merge)

After the squash merge, **immediately** merge `main` back into `staging`:

```bash
git checkout staging
git pull origin staging
git merge main -m "Merge main back into staging after release_YYYY-MM-DD"
git push origin staging
```

**Why this is critical:**
- The merge commit marks the synchronization point
- Future commit analyses will start from this point
- Prevents already-merged commits from appearing in future promotions

### 3. Continue Development

Continue adding commits to `staging`. The commit analysis will automatically:
- Find the last merge commit where `main` was brought into `staging`
- Analyze only commits added after that point
- Exclude any commits whose content already exists in `main`

## How Commit Analysis Works

The `production-release.yml` workflow:

1. **Finds the sync point:**
   ```bash
   # Look for merge commits in staging where main was merged
   git log HEAD --merges --grep="Merge.*main"
   ```

2. **Gets commits since sync:**
   ```bash
   # Get all commits after the sync point
   git rev-list ${SYNC_POINT}..HEAD --no-merges
   ```

3. **Filters by content:**
   ```bash
   # Double-check content isn't already in main
   git cherry -v main HEAD
   ```

## Best Practices

### ✅ DO

- **Always merge `main` back into `staging`** after a production release
- Use descriptive commit messages
- Include PR numbers in merge commit messages for traceability
- Test in staging before promoting to main

### ❌ DON'T

- Don't rebase `staging` onto `main` (breaks commit tracking)
- Don't force-push to `staging` (loses history)
- Don't skip the main→staging merge (breaks future analyses)
- Don't use "Merge commit" when merging staging→main PR (defeats the purpose of squashing)

## Troubleshooting

### Issue: Workflow shows too many commits

**Symptom:** The production release workflow lists commits that were already promoted.

**Cause:** The last main→staging merge is missing or wasn't detected.

**Solution:**
1. Check the staging history for merge commits:
   ```bash
   git log staging --merges --grep="main" --oneline
   ```
2. If no recent merge exists, manually merge `main` into `staging`:
   ```bash
   git checkout staging
   git merge main -m "Sync: Merge main into staging"
   git push origin staging
   ```

### Issue: Workflow shows no commits but there are changes

**Symptom:** The workflow reports no commits to promote, but you know there are new changes.

**Cause:** The changes might have been cherry-picked to `main` or the content is already there.

**Solution:**
1. Check the actual diff:
   ```bash
   git diff main..staging
   ```
2. If there are real differences, the workflow should detect them. If not, file an issue.

## Technical Details

### Why Not Use Tags?

Initially, we tried using release tags on `main` to track what was promoted:
- **Problem:** Tags point to squash commits on `main` that aren't in `staging`'s history
- **Result:** `git` commands like `tag..HEAD` on `staging` would include all commits, even merged ones

### Why Not Use Git Cherry Alone?

`git cherry` compares patch content between branches:
- **Problem:** Squash merges can change patch-IDs due to context differences
- **Result:** Already-squashed commits might still appear as "new"

### Our Hybrid Approach

1. **First:** Use merge commits to find the sync point (reliable)
2. **Then:** Use `git cherry` as a safety check (catches edge cases)
3. **Result:** Accurate commit identification even with complex squash-merge workflows

## References

- [GitHub Documentation: About merge methods](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/about-merge-methods-on-github)
- [Git Cherry Documentation](https://git-scm.com/docs/git-cherry)
- [Pro Git Book: Merge Strategies](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
