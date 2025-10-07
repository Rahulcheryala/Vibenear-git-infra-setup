# Branch Protection Rules Setup Guide

This document outlines the branch protection rules that need to be configured in GitHub to secure your Git infrastructure.

## 🔒 Required Branch Protection Rules

### 1. Main Branch Protection

**Branch**: `main`

**Protection Rules**:

- ✅ **Require a pull request before merging**

  - Require approvals: `2` (recommended for production)
  - Dismiss stale PR approvals when new commits are pushed: `Yes`
  - Require review from code owners: `Yes` (if CODEOWNERS file exists)

- ✅ **Require status checks to pass before merging**

  - Require branches to be up to date before merging: `Yes`
  - Required status checks:
    - `Branch Naming Convention Check`
    - `Deploy to Production` (if you want to ensure deployment passes)
    - Any other CI checks you have

- ✅ **Require conversation resolution before merging**: `Yes`

- ✅ **Require signed commits**: `Yes` (recommended for production)

- ✅ **Require linear history**: `Yes` (prevents merge commits)

- ✅ **Include administrators**: `No` (even admins must follow rules)

- ✅ **Restrict pushes that create files**: `Yes`

- ✅ **Allow force pushes**: `No`

- ✅ **Allow deletions**: `No`

### 2. Staging Branch Protection

**Branch**: `staging`

**Protection Rules**:

- ✅ **Require a pull request before merging**

  - Require approvals: `1`
  - Dismiss stale PR approvals when new commits are pushed: `Yes`

- ✅ **Require status checks to pass before merging**

  - Require branches to be up to date before merging: `Yes`
  - Required status checks:
    - `Branch Naming Convention Check`
    - `Deploy to Staging`

- ✅ **Require conversation resolution before merging**: `Yes`

- ✅ **Allow force pushes**: `No`

- ✅ **Allow deletions**: `No`

### 3. Develop Branch Protection

**Branch**: `develop`

**Protection Rules**:

- ✅ **Require a pull request before merging**

  - Require approvals: `1`
  - Dismiss stale PR approvals when new commits are pushed: `Yes`

- ✅ **Require status checks to pass before merging**

  - Required status checks:
    - `Branch Naming Convention Check`

- ✅ **Allow force pushes**: `No`

- ✅ **Allow deletions**: `No`

## 🛠️ How to Configure Branch Protection Rules

### Via GitHub Web Interface:

1. **Navigate to Repository Settings**:

   - Go to your repository on GitHub
   - Click on `Settings` tab
   - Click on `Branches` in the left sidebar

2. **Add Branch Protection Rule**:
   - Click `Add rule` or `Add branch protection rule`
   - Enter the branch name pattern (e.g., `main`, `staging`, `develop`)
   - Configure the protection settings as outlined above
   - Click `Create` or `Save changes`

### Via GitHub CLI:

```bash
# Protect main branch
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Branch Naming Convention Check","Deploy to Production"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":2,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field required_conversation_resolution=true \
  --field required_signatures=true \
  --field require_linear_history=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false

# Protect staging branch
gh api repos/:owner/:repo/branches/staging/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Branch Naming Convention Check","Deploy to Staging"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field required_conversation_resolution=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false

# Protect develop branch
gh api repos/:owner/:repo/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Branch Naming Convention Check"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

## 🔧 Default Branch Configuration

### Set Develop as Default Branch:

1. **Via GitHub Web Interface**:

   - Go to Repository Settings → General
   - Under "Default branch", click the switch icon
   - Select `develop` from the dropdown
   - Click `Update`

2. **Via GitHub CLI**:

```bash
gh api repos/:owner/:repo --method PATCH --field default_branch=develop
```

## 📋 Additional Recommendations

### 1. Create CODEOWNERS File

Create `.github/CODEOWNERS` file to automatically request reviews from code owners:

```gitignore
# Global owners
* @your-team-lead @senior-developer

# Specific file patterns
*.md @documentation-team
.github/workflows/ @devops-team
```

### 2. Configure Merge Options

In Repository Settings → General → Pull Requests:

- ✅ **Allow merge commits**: `Yes`
- ✅ **Allow squash merging**: `Yes`
- ✅ **Allow rebase merging**: `Yes`
- ✅ **Automatically delete head branches**: `Yes`

### 3. Restrict Base Branches for PRs (Prevent Back-Merging)

⚠️ **CRITICAL**: To prevent accidental back-merging (e.g., main → staging), configure allowed PR base branches:

**For Main Branch Protection:**
- Only allow PRs from `staging` branch
- This prevents accidentally merging main back to lower environments

**For Staging Branch Protection:**
- Only allow PRs from `develop` branch
- This prevents merging main or other branches to staging

**For Develop Branch Protection:**
- Only allow PRs from `feature/*`, `hotfix/*`, and `bugfix/*` branches
- This prevents merging staging or main back to develop

**How to Configure:**
1. In GitHub Settings → Branches → Branch protection rules
2. Under "Restrict who can push to matching branches"
3. Or use CODEOWNERS to enforce that only automation can create PRs between main branches

**Note**: GitHub doesn't have a native "restrict PR source branches" feature, but you can:
- Use a GitHub Action to validate PR source/target branches
- Add this to your PR validation workflows
- Train team members on the one-way flow rule

### 4. Set Up Required Status Checks

Make sure your workflows are properly configured as required status checks:

- `Branch Naming Convention Check`
- `Deploy to Staging`
- `Deploy to Production`

## 🧪 Testing Branch Protection

After setting up protection rules, test them by:

1. **Test Force Push Protection**:

   ```bash
   git push --force-with-lease origin main
   # Should fail with protection error
   ```

2. **Test Direct Push Protection**:

   ```bash
   git push origin main
   # Should fail, requiring PR
   ```

3. **Test PR Requirements**:
   - Create a PR without required checks
   - Verify it cannot be merged until checks pass

## ⚠️ Important Notes

### One-Way Flow Protection

**CRITICAL**: This workflow is designed as a **one-way promotion flow only**:
- feature → develop → staging → main ✅
- main → staging → develop ❌ NEVER

**Why this matters:**
- Commits are squashed at different stages
- Merging backwards would rewrite history and create conflicts
- Staging contains detailed feature branch history that main doesn't have
- Back-merging would duplicate commits with different SHAs

**Prevention strategies:**
1. Train all team members on the one-way flow rule
2. Consider adding a GitHub Action to block PRs with wrong source/target
3. Use CODEOWNERS or branch restrictions where possible
4. Regular code reviews should catch any incorrect PR directions

### Hotfix Strategy

For emergency fixes, **always start from develop** and fast-track through the normal flow:
- Create `hotfix/` branch from develop (NOT from main)
- Follow normal promotion: develop → staging → main
- Expedite reviews but maintain the flow integrity

### Backup and Emergency Access

- **Backup Access**: Ensure at least one admin has direct access to modify protection rules
- **Gradual Rollout**: Start with less restrictive rules and tighten them as the team adapts
- **Emergency Override**: Have a process for emergency deployments that bypass protection rules
- **Regular Review**: Periodically review and update protection rules based on team needs

---

**🔗 Related Documentation**:

- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
