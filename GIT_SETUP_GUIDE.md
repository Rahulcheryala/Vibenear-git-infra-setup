# Git Infrastructure Setup Guide

## Overview
This repository implements a comprehensive Git branching strategy and CI/CD pipeline setup for a development workflow with feature branches, automated deployments, and quality gates.

## Branching Strategy

### Branch Hierarchy
```
main (Production)
├── staging (QA Testing)
    ├── develop (Integration)
        ├── feature/user-authentication
        ├── feature/payment-gateway
        └── feature/dashboard-redesign
```

### Branch Descriptions
- **`main`**: Production-ready code, deployed to production environment with prod DB
- **`staging`**: QA testing environment, deployed to staging environment with staging DB
- **`develop`**: Integration branch for developers, connected to local/dev databases
- **`feature/*`**: Individual feature branches created from develop

## Quick Start

### 1. Initial Setup
Run the setup script to create the branch structure:
```bash
./scripts/setup-branches.sh
```

### 2. GitHub Configuration
After creating branches, configure in GitHub Settings:

#### Repository Settings
1. Go to **Settings > General > Pull Requests**
2. Enable "Allow squash merging" only
3. Disable "Allow merge commits" and "Allow rebase merging"
4. Set default commit message to "Pull request title"

#### Branch Protection Rules

**Main Branch Protection:**
- Settings > Branches > Add rule for `main`
- ✅ Require pull request reviews (minimum 1 senior developer)
- ✅ Dismiss stale reviews when new commits are pushed
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Include administrators in restrictions
- ✅ Restrict pushes and force pushes

**Staging Branch Protection:**
- Settings > Branches > Add rule for `staging`
- ✅ Require pull request reviews (minimum 1 reviewer)
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Include administrators in restrictions
- ✅ Restrict pushes and force pushes

**Develop Branch Protection:**
- Settings > Branches > Add rule for `develop`
- ✅ Require pull request reviews (minimum 1 reviewer)
- ✅ Require status checks to pass before merging
- ✅ Allow squash merging only

## Developer Workflow

### Feature Development Process

1. **Start from develop branch:**
```bash
git checkout develop
git pull origin develop
```

2. **Create feature branch (following naming convention):**
```bash
git checkout -b feature/user-authentication
```

3. **Work on feature, make commits:**
```bash
git add .
git commit -m "Add login functionality"
git commit -m "Add password validation"
git commit -m "Add error handling"
```

4. **Push feature branch:**
```bash
git push -u origin feature/user-authentication
```

5. **Create PR to develop (GitHub UI):**
- Branch naming will be automatically validated
- Squash merge will be enforced

### Promotion Process

#### Develop to Staging
Use the promotion script:
```bash
./scripts/promote-to-staging.sh
```

Or manually trigger the GitHub Action:
- Go to Actions > "Promote to Staging Helper"
- Click "Run workflow" from develop branch

#### Staging to Main
Use the promotion script:
```bash
./scripts/promote-to-main.sh
```

## GitHub Actions Workflows

### Automated Workflows

1. **Branch Naming Check** (`.github/workflows/branch-naming-check.yml`)
   - Validates feature branch names follow `feature/[a-z0-9-]+` pattern
   - Provides helpful error messages with fix instructions

2. **Staging Deploy** (`.github/workflows/staging-deploy.yml`)
   - Automatically deploys on push to `staging` branch
   - Runs tests and builds before deployment

3. **Production Deploy** (`.github/workflows/production-deploy.yml`)
   - Automatically deploys on push to `main` branch
   - Creates deployment tags
   - Runs comprehensive tests

4. **Staging Promotion Helper** (`.github/workflows/staging-promotion.yml`)
   - Manual workflow to create staging promotion PRs
   - Lists included features and provides QA checklist

## Environment Configuration

Environment-specific configurations are stored in `.github/environments/`:

- **Development**: `development.yml` - Local development settings
- **Staging**: `staging.yml` - QA testing environment
- **Production**: `production.yml` - Live production environment

## Best Practices

### Merge Strategy

- **Feature → Develop**: ✅ **Squash merge** (clean history, easy revert)
- **Develop → Staging**: ❌ **Regular merge** (preserve testing context)
- **Staging → Main**: ❌ **Regular merge** (maintain release traceability)

⚠️ **CRITICAL: One-Way Flow Only**

This is a **strictly one-way promotion flow**. NEVER merge backwards:
- ❌ **NEVER merge main → staging** (will rewrite staging history)
- ❌ **NEVER merge staging → develop** (will rewrite develop history)
- ❌ **NEVER merge main → develop** (will rewrite develop history)

**Why?** When commits are squashed during promotion to staging or main, the commit history is rewritten. Merging back would create conflicts and lose the detailed history of feature branches that staging and develop preserve.

### Branch Naming Convention
All feature branches must follow the pattern: `feature/descriptive-name`

Examples:
- ✅ `feature/user-authentication`
- ✅ `feature/payment-gateway`
- ✅ `feature/dashboard-redesign`
- ❌ `feature/UserAuth` (no uppercase)
- ❌ `feat/user-auth` (wrong prefix)

### Commit Messages
- Use descriptive commit messages
- Start with a verb (Add, Fix, Update, Remove)
- Keep first line under 50 characters
- Use present tense

## Troubleshooting

### Branch Naming Issues
If your branch name is rejected:
1. Rename your branch: `git branch -m old-name feature/new-name`
2. Delete old remote: `git push origin --delete old-name`
3. Push new branch: `git push origin feature/new-name`
4. Set upstream: `git branch --set-upstream-to=origin/feature/new-name`

### Failed Deployments
Check the Actions tab for detailed error logs. Common issues:
- Missing environment variables
- Test failures
- Build errors

### Merge Conflicts
When promoting between branches:
1. Ensure your local branch is up to date
2. Resolve conflicts locally before pushing
3. Test thoroughly after conflict resolution

⚠️ **Important**: Only promote forward (develop → staging → main). Never merge backwards to avoid history corruption.

### Hotfixes and Emergency Fixes

If you need to deploy an urgent fix to production:

1. **Create hotfix branch from develop** (NOT from main):
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b hotfix/critical-bug-fix
   ```

2. **Make the fix and push**:
   ```bash
   git add .
   git commit -m "Fix critical bug"
   git push -u origin hotfix/critical-bug-fix
   ```

3. **Follow the normal promotion flow**:
   - Create PR to develop (squash merge)
   - Auto-promotion to staging
   - Manual promotion to main

4. **For true emergencies**, you can expedite reviews and approvals, but always maintain the one-way flow.

**Why not branch from main?** Because main has squashed commits. Starting from main would create divergent histories and merge conflicts when trying to integrate back to develop/staging.

## Scripts Reference

- `setup-branches.sh` - Initial branch structure creation
- `promote-to-staging.sh` - Promote develop to staging
- `promote-to-main.sh` - Promote staging to main

## Additional Recommendations

1. **Feature Flags**: Implement feature flags for safer deployments
2. **Monitoring**: Set up monitoring and alerting for each environment
3. **Security**: Regular security scanning in CI/CD pipeline
4. **Documentation**: Maintain changelog and release notes
5. **Testing**: Comprehensive test coverage at all levels

## Support

For issues with this setup:
1. Check the Actions logs for detailed error messages
2. Verify branch protection rules are correctly configured
3. Ensure all required environment variables are set
4. Review the troubleshooting section above

**Important**: Read [ONE_WAY_FLOW.md](./ONE_WAY_FLOW.md) to understand why backwards merging is forbidden and how to handle hotfixes correctly.

This setup ensures code quality, maintains clean history, and provides safe deployment practices across all environments.