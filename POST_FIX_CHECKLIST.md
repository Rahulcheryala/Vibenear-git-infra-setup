# Post-Fix Checklist

## What Was Fixed

The production release workflow (`production-release.yml`) was incorrectly identifying already-merged commits as new commits to promote. This happened because:

- The workflow used release tags on main's squash commits to find new commits
- After squash merging, tags point to commits that don't exist in staging's history
- `git cherry` couldn't reliably filter out squashed commits

**Fix:** Changed to find merge commits where main was merged back into staging as synchronization points.

## Immediate Actions Required

### 1. Merge Main Back into Staging (One-Time)

Since the last production release (PR #7), main hasn't been merged back into staging. You need to do this now:

```bash
# On your local machine
git checkout staging
git pull origin staging
git merge main -m "Sync: Merge main into staging after PR #7"
git push origin staging
```

**Why:** This creates a synchronization point that the workflow can use to correctly identify new commits.

### 2. Test the Workflow

After merging main into staging:

```bash
# Trigger the production release workflow manually
# It should now show only the truly new commits (currently 5 commits)
# Not the 18 commits it was showing before
```

Expected output:
- ✅ 5 commits identified for promotion
- ❌ NOT 18 or 36 commits

## Ongoing Process Changes

### After Every Production Release

From now on, **always** follow this pattern:

1. **Create staging→main PR** using the production release workflow
2. **Review and merge** the PR (using "Squash and merge")
3. **Immediately merge main back into staging:**
   ```bash
   git checkout staging
   git pull origin staging
   git merge main -m "Sync: Merge main into staging after release_YYYY-MM-DD"
   git push origin staging
   ```

### Why This Is Critical

- The merge commit marks the synchronization point
- Future commit analyses start from this point
- Without it, already-merged commits will incorrectly appear again

### Can This Be Automated?

Yes! Consider creating a GitHub Action that automatically:
1. Triggers when a PR is merged to main from staging
2. Creates a PR to merge main back into staging
3. Optionally auto-merges if no conflicts

Example trigger:
```yaml
on:
  pull_request:
    types: [closed]
    branches: [main]
```

## Verification

To verify the fix is working:

1. Check the most recent merge in staging:
   ```bash
   git log staging --merges --grep="main" --oneline -5
   ```
   You should see a recent merge after PR #7

2. Run a test analysis:
   ```bash
   # From staging branch
   SYNC=$(git log --merges --grep="main" --format=%H | head -1)
   git rev-list --no-merges --oneline ${SYNC}..HEAD
   ```
   Should show only new commits since the last sync

## Troubleshooting

### Workflow still shows too many commits

**Check:** When was main last merged into staging?
```bash
git log staging --merges --grep="main" --oneline -1
```

**Fix:** Merge main into staging following the steps above

### No merge commit found

**Check:** Are you using the squash merge workflow correctly?
- staging→main should use "Squash and merge"
- main→staging should use regular "Create a merge commit"

## Documentation

Refer to these documents for more information:

- `SQUASH_MERGE_WORKFLOW.md` - Complete guide to the squash merge pattern
- `WORKFLOW_IMPLEMENTATION_GUIDE.md` - Overall workflow documentation
- `.github/workflows/production-release.yml` - The fixed workflow with inline comments

## Questions?

If you encounter issues or have questions:

1. Check the troubleshooting section in `SQUASH_MERGE_WORKFLOW.md`
2. Review the commit history to see how the fix was implemented
3. Open an issue with details about what's not working
