# One-Way Flow: Why Back-Merging Is Forbidden

## TL;DR

**NEVER merge backwards in this workflow:**
- ❌ main → staging
- ❌ staging → develop  
- ❌ main → develop

**Why?** Commits are squashed at each stage, creating different SHAs. Back-merging would corrupt history and create conflicts.

---

## The Problem

This repository implements a **one-way promotion flow** with commit squashing:

```
feature → develop → staging → main
(detailed) (detailed) (squashed) (single commit)
```

### What Happens at Each Stage

1. **Feature → Develop**: Individual commits preserved
2. **Develop → Staging**: May squash by feature branch
3. **Staging → Main**: All commits squashed into ONE release commit

### Example

**In Develop:**
```
abc123 feat: Add login form
def456 feat: Add validation
ghi789 feat: Add error handling
```

**After Staging → Main (squashed):**
```
xyz999 release: Production deployment 2024-01-15 (contains abc123, def456, ghi789)
```

Notice: The original commits (abc123, def456, ghi789) have been **replaced** with a single commit (xyz999).

## Why Back-Merging Breaks Things

If you try to merge `main` back to `staging`:

1. **Git sees different commits**: xyz999 in main vs abc123+def456+ghi789 in staging
2. **Git thinks they're all new**: Even though they contain the same code changes
3. **Merge conflicts everywhere**: Git tries to merge identical code with different SHAs
4. **History corruption**: You'd lose the detailed commit history that staging preserves

### Visual Example

```
# Before bad back-merge
Staging:  abc123 → def456 → ghi789
Main:     xyz999 (squashed version of above)

# After bad back-merge (DON'T DO THIS!)
Staging:  abc123 → def456 → ghi789 → [merge xyz999] ← DUPLICATE COMMITS!
```

Now staging has both:
- The original detailed commits (abc123, def456, ghi789)
- AND the squashed commit (xyz999) which contains the same changes

This creates:
- Duplicate code
- Merge conflicts on every file
- Broken git history
- Confusion about which commits are "real"

## The Correct Way

### For Bug Fixes After Production Release

❌ **Wrong:**
```bash
git checkout main
git checkout -b hotfix/bug-fix
# Work on fix, then merge back to staging
```

✅ **Correct:**
```bash
git checkout develop
git checkout -b hotfix/bug-fix
# Work on fix
# Follow normal flow: develop → staging → main
```

### For Emergency Hotfixes

Even in emergencies, **start from develop** and fast-track through the flow:
1. Create hotfix from develop
2. Expedite review for develop merge
3. Expedite staging promotion
4. Expedite production deployment

**Time saved by skipping stages: 10 minutes**  
**Time lost fixing broken git history: 2 days**

## How We Prevent Back-Merging

1. **Documentation**: This file and related guides
2. **Team Training**: All developers must understand the one-way flow
3. **Automated Checks**: `.github/workflows/prevent-back-merge.yml` blocks invalid PRs
4. **Code Reviews**: Reviewers should reject any backwards PR
5. **Branch Protection**: Configure GitHub to restrict PR base branches

## What If It Already Happened?

If someone already merged backwards and broke the history:

### Option 1: Revert the Merge (Recommended)
```bash
# If the back-merge was the last commit
git revert -m 1 <merge-commit-sha>
git push
```

### Option 2: Reset Branch (Destructive)
```bash
# Only if no one else has pulled the broken history
git checkout staging
git reset --hard <commit-before-merge>
git push --force  # Requires disabled branch protection
```

### Option 3: Recreate Branch (Nuclear Option)
```bash
# Last resort: Recreate from develop
git branch -D staging
git checkout develop
git checkout -b staging
git push --force origin staging  # Requires disabled branch protection
```

⚠️ **Warning**: Options 2 and 3 require force-pushing and will affect everyone on the team.

## FAQ

**Q: What if production has a bug that's not in staging/develop?**  
**A:** That shouldn't happen with this workflow! Main only gets code from staging, and staging only gets code from develop. The bug must exist in one of those branches. Start your fix from develop.

**Q: What if I need to sync a hotfix that went to main only?**  
**A:** That's a workflow violation. Hotfixes should ALWAYS go through develop → staging → main. If it happened, manually apply the same fix to develop (don't merge backwards).

**Q: Can I cherry-pick from main to staging?**  
**A:** No! Cherry-picking is just another form of back-merging. Apply the fix to develop instead.

**Q: What about merge conflicts during promotion?**  
**A:** Conflicts during **forward** promotion (develop → staging → main) are normal and should be resolved. The issue is only with **backward** merging.

## References

- [GIT_SETUP_GUIDE.md](./GIT_SETUP_GUIDE.md) - Complete workflow documentation
- [WORKFLOW_IMPLEMENTATION_GUIDE.md](./WORKFLOW_IMPLEMENTATION_GUIDE.md) - Implementation details
- [BRANCH_PROTECTION_SETUP.md](./BRANCH_PROTECTION_SETUP.md) - Security configuration

---

**Remember**: The one-way flow is not a suggestion—it's a requirement for maintaining clean git history!
