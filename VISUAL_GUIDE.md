# Visual Guide: Squash Merge Commit Tracking

## The Problem

### Before Fix: Tag-Based Tracking ❌

```
staging:  A → B → C → D → E → F → G
                  ↓ (squash merge PR #7)
main:             X [tag: release_04-10]
```

**Issue:** Tag `release_04-10` points to commit X on main, which is NOT in staging's history.

When analyzing commits:
```bash
# Workflow tried: tag..HEAD on staging
git rev-list release_04-10..HEAD

# Problem: Tag isn't in staging's history!
# Result: Shows ALL commits (A through G)
```

**Output:** 18 commits (all commits from before the tag)

---

## The Solution

### After Fix: Sync Point Tracking ✅

```
staging:  A → B → C → D → E → F → G
                  ↓ (squash merge PR #7)
main:             X
                  ↓ (merge back - creates sync point)
staging:  A → B → C → M → D → E → F → G
                      ↑
                  Sync Point
```

**Key:** Merge commit M marks where staging was synchronized with main.

When analyzing commits:
```bash
# Workflow now: sync_point..HEAD on staging
git rev-list M..HEAD

# Sync point M IS in staging's history!
# Result: Shows only D, E, F, G (new commits)
```

**Output:** 5 commits (only new commits since last sync)

---

## Detailed Flow

### Step 1: Create Production PR

```
staging:  A → B → C → D → E → F
          ↓
    Analyze commits
          ↓
    Create PR #7 (staging → main)
```

### Step 2: Squash Merge PR

```
PR #7 contains: A, B, C, D, E, F
          ↓ (squash merge)
main:     X [A+B+C+D+E+F combined]
          
Tag: release_04-10 → X
```

### Step 3: Merge Main Back (Critical!)

```
main:     X
          ↓ (merge into staging)
staging:  A → B → C → D → E → F → M
                                  ↑
                            Sync Point
```

### Step 4: Continue Development

```
staging:  ... → M → G → H → I
                ↑       ↑   ↑
          Sync Point    New commits
```

### Step 5: Next Production Release

```
# Workflow analyzes M..HEAD
# Shows only: G, H, I
# Does NOT show: A, B, C, D, E, F (already in main via X)
```

---

## Real Example from Repository

### Current State

```
staging:
  747c01e [WIP] Fix workflow (#10)  ← HEAD
  4c26261 minor fix
  541145f testing
  77dbf42 refactor: removed job descriptions
  94a7a65 test PR analysis
  51794c4 Merge main into staging  ← SYNC POINT
  b906bfa refactor: Revise production release
  ...
  922310d Refactor auto-promotion
  831e18d fix: minor syntax issue
  ...

main:
  c3d3224 🚀 Production Release PR #7  ← HEAD
          [tag: release_04-10-2025_22.06.19]
```

### Analysis

**Sync Point:** `51794c4` (Merge main into staging)

**Commits since sync:** `51794c4..HEAD` = 5 commits
- 94a7a65 test PR analysis
- 77dbf42 refactor: removed job descriptions
- 541145f testing
- 4c26261 minor fix
- 747c01e [WIP] Fix workflow (#10)

**Commits before sync:** (NOT included)
- 922310d Refactor auto-promotion ← Was in PR #7
- 831e18d fix: minor syntax issue ← Was in PR #7
- ... (16 more commits from PR #7)

---

## Why Git Cherry Alone Doesn't Work

```
staging:  A → B → C → D → E
                  ↓ (squash)
main:             X

# git cherry compares patches
git cherry main staging

# Problem: Squashing changes patch-ids
# A's patch-id ≠ X's patch-id
# B's patch-id ≠ X's patch-id
# C's patch-id ≠ X's patch-id

# Result: A, B, C marked as "new" even though
# their content is in X!
```

**Solution:** Use sync points as primary filter, git cherry as secondary verification.

---

## Best Practices Diagram

### ✅ Correct Flow

```
1. Develop → Staging → Main
                ↓
         (squash merge)
                ↓
2. Main → Staging
         ↓
   (create sync point)
         ↓
3. Continue development
         ↓
4. Next release uses sync point
```

### ❌ Incorrect Flow

```
1. Develop → Staging → Main
                ↓
         (squash merge)
                ↓
   ⚠️  SKIP merging main back
                ↓
2. Continue development
         ↓
   ⚠️  No sync point!
         ↓
3. Next release shows ALL commits
   (including already-merged ones)
```

---

## Git Commands Reference

### Find Sync Point
```bash
git log HEAD --merges --grep="merge.*main" --format="%H %s"
```

### Count New Commits
```bash
SYNC=$(git log HEAD --merges --grep="merge.*main" --format=%H | head -1)
git rev-list --count --no-merges ${SYNC}..HEAD
```

### List New Commits
```bash
git rev-list --no-merges --oneline ${SYNC}..HEAD
```

### Verify Not in Main
```bash
git cherry -v main HEAD | grep "^+"
```
