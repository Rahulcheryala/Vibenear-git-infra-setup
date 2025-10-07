# Git Infrastructure Setup Test

Enterprise-grade Git workflow infrastructure with automated deployments, branch protection, and squash merge support.

## 🚀 Quick Start

This repository demonstrates a complete Git workflow setup for:
- Feature development with branch naming conventions
- Automated staging promotions
- Production releases with squash merge strategy
- Commit analysis and PR automation

## 📚 Documentation

### Getting Started
- **[GIT_SETUP_GUIDE.md](GIT_SETUP_GUIDE.md)** - Initial setup and developer workflow
- **[WORKFLOW_IMPLEMENTATION_GUIDE.md](WORKFLOW_IMPLEMENTATION_GUIDE.md)** - Complete workflow implementation guide
- **[BRANCH_PROTECTION_SETUP.md](BRANCH_PROTECTION_SETUP.md)** - Branch protection rules configuration

### Squash Merge Workflow
- **[SQUASH_MERGE_WORKFLOW.md](SQUASH_MERGE_WORKFLOW.md)** - ⭐ **START HERE** - Understanding the squash merge pattern
- **[VISUAL_GUIDE.md](VISUAL_GUIDE.md)** - Visual diagrams of commit tracking
- **[POST_FIX_CHECKLIST.md](POST_FIX_CHECKLIST.md)** - Actions to take after recent fixes

## 🔄 Workflow Overview

```
feature/branch → develop → staging → main
     ↓              ↓         ↓        ↓
   PR Review    Auto PR    Squash    Release
                           Merge
                             ↓
                        Main → Staging
                           (sync)
```

### Branch Strategy
- **feature/**, **bugfix/**, **hotfix/** - Feature development branches
- **develop** - Integration branch (not yet implemented)
- **staging** - Pre-production testing environment
- **main** - Production branch

### Key Workflows
1. **Branch Naming Check** - Validates branch naming conventions
2. **Auto Promote to Production** - Creates staging→main PRs
3. **Production Deploy** - Deploys on merge to main
4. **Staging Deploy** - Deploys on push to staging

## 🎯 Critical: Squash Merge Pattern

**Important:** This repository uses squash merges for production releases. After each merge to main:

1. ✅ Merge the PR using "Squash and merge"
2. ✅ **Immediately** merge main back into staging:
   ```bash
   git checkout staging
   git merge main -m "Sync: Merge main into staging after release"
   git push origin staging
   ```

**Why?** This creates a synchronization point that allows accurate commit tracking for future releases.

See [SQUASH_MERGE_WORKFLOW.md](SQUASH_MERGE_WORKFLOW.md) for detailed explanation.

## 🛠️ Workflows

### Core Workflows
- `.github/workflows/branch-naming-check.yml` - Enforces branch naming
- `.github/workflows/staging-deploy.yml` - Deploys to staging
- `.github/workflows/production-deploy.yml` - Deploys to production

### Automation Workflows
- `.github/workflows/production-release.yml` - Creates production promotion PRs
- `.github/workflows/staging-pr-analysis.yml` - Analyzes staging PRs
- `.github/workflows/tag-on-merge.yml` - Creates release tags

## 📊 Recent Improvements

### Fixed Commit Analysis (Oct 2025)

**Problem:** Production release workflow incorrectly showed 18 already-merged commits as new.

**Root Cause:** After squash merging, the workflow couldn't track which commits were already in main.

**Solution:** Changed to sync-point-based tracking using merge commits where main is merged back into staging.

**Result:** Now correctly identifies only 5 new commits instead of 18.

See [POST_FIX_CHECKLIST.md](POST_FIX_CHECKLIST.md) for actions needed.

## 🧪 Testing

Run the workflow testing script:

```bash
./scripts/test-git-workflow.sh
```

This validates:
- Branch naming conventions
- Workflow files existence
- Deployment script simulation
- Optional full workflow testing

## 📋 Checklist for New Deployments

- [ ] Configure branch protection rules (see BRANCH_PROTECTION_SETUP.md)
- [ ] Set up required status checks
- [ ] Configure deployment secrets/environments
- [ ] Update deployment scripts with actual commands
- [ ] Test the complete workflow with a feature branch
- [ ] Ensure main→staging sync after first production release

## 🔍 Troubleshooting

### Workflow shows too many commits
- Check when main was last merged into staging
- Merge main into staging to create a sync point

### Branch naming check fails
- Use format: `feature/description`, `bugfix/description`, or `hotfix/description`
- Use lowercase and hyphens only

### Can't merge to protected branch
- Ensure required status checks pass
- Get required number of approvals
- Resolve all conversations

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make changes and commit: `git commit -m "feat: your feature"`
3. Push and create PR: `git push origin feature/your-feature`
4. Ensure branch naming check passes
5. Get required approvals
6. Merge using appropriate method (squash for main, regular for staging)

## 📞 Support

- Check documentation in the root directory
- Review workflow files for inline comments
- See troubleshooting sections in guides
- File an issue for unexpected behavior

## 🔗 Related Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Git Branching Strategies](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows)
- [Squash Merging](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/about-pull-request-merges#squash-and-merge-your-commits)

---

**Status:** ✅ Production Ready | **Last Updated:** October 2025
