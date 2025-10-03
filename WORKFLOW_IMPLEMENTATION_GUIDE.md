# Git Workflow Implementation Guide

## 🎯 Overview

This guide provides a comprehensive implementation plan for your industry-grade Git infrastructure with proper branching strategy, approval processes, and automated deployments.

## 📋 Implementation Checklist

### Phase 1: Initial Setup ✅

- [x] Enhanced branch naming convention (feature/, bugfix/, hotfix/)
- [x] Created commit squashing workflows
- [x] Created automated PR promotion workflows
- [x] Created branch protection documentation
- [x] Created comprehensive testing script

### Phase 2: GitHub Configuration (Manual Steps Required)

#### 2.1 Branch Protection Rules

Follow the detailed guide in `BRANCH_PROTECTION_SETUP.md`:

1. **Protect main branch**:

   - Require 2 PR approvals
   - Require status checks
   - Disable force pushes and deletions
   - Require signed commits

2. **Protect staging branch**:

   - Require 1 PR approval
   - Require status checks
   - Disable force pushes and deletions

3. **Protect develop branch**:
   - Require 1 PR approval
   - Require status checks
   - Disable force pushes and deletions

#### 2.2 Default Branch Configuration

- Set `develop` as the default branch in repository settings

#### 2.3 Required Status Checks

Configure these workflows as required status checks:

- `Branch Naming Convention Check`
- `Deploy to Staging`
- `Deploy to Production`

### Phase 3: Testing the Workflow

#### 3.1 Run the Testing Script

```bash
# Make the script executable (Linux/Mac)
chmod +x scripts/test-git-workflow.sh

# Run the test
./scripts/test-git-workflow.sh
```

#### 3.2 Manual Testing Steps

1. **Test Feature Branch Creation**:

   ```bash
   # Create a feature branch
   git checkout develop
   git checkout -b feature/test-workflow

   # Make some commits
   echo "test content" > test.txt
   git add test.txt
   git commit -m "feat(feature/test-workflow): Add test functionality"

   # Push and create PR to develop
   git push -u origin feature/test-workflow
   ```

2. **Test Staging Promotion**:

   - After merging feature PR to develop
   - The `auto-promote-staging.yml` workflow should automatically create a PR from develop to staging
   - Review and merge the staging promotion PR

3. **Test Production Deployment**:
   - Run the `auto-promote-production.yml` workflow manually
   - Review and merge the production deployment PR

## 🔄 Workflow Overview

### Branch Flow

```
feature/branch → develop → staging → main
     ↓              ↓         ↓        ↓
   PR Review    Auto PR    Auto PR   Release
```

### Commit Squashing Strategy

1. **Feature → Develop**: Keep individual commits for detailed history
2. **Develop → Staging**: Squash by feature branch (e.g., 3 feature branches = 3 squashed commits)
3. **Staging → Main**: Squash all to single release commit

### Example Scenario

**Initial State**:

- 3 feature branches with 5 commits each = 15 commits in develop

**Develop → Staging**:

- 15 commits squashed into 3 commits (one per feature)
- Commit messages: `feat: feature/test1 - last commit message`, etc.

**Staging → Main**:

- 3 commits squashed into 1 release commit
- Commit message: `release: Production deployment 2024-01-15 14:30:00 UTC (v2024.01.15-1430)`

## 🛠️ Workflow Files Created

### Core Workflows

1. **branch-naming-check.yml**: Enforces branch naming conventions
2. **staging-deploy.yml**: Deploys to staging on merge
3. **production-deploy.yml**: Deploys to production on merge

### Squashing Workflows

4. **develop-to-staging-squash.yml**: Analyzes and comments on develop→staging PRs
5. **staging-to-main-squash.yml**: Analyzes and comments on staging→main PRs

### Automation Workflows

6. **auto-promote-staging.yml**: Auto-creates PRs from develop to staging
7. **auto-promote-production.yml**: Manual trigger to create PRs from staging to main

## 🧪 Testing Strategy

### Automated Testing

The `test-git-workflow.sh` script provides:

- Branch naming convention validation
- Workflow file existence checks
- Deployment script simulation
- Optional full workflow testing with test commits

### Manual Testing

1. Create actual feature branches and PRs
2. Test the staging promotion workflow
3. Test the production deployment workflow
4. Verify branch protection rules work correctly

## 📊 Expected Workflow Behavior

### Feature Development

1. Developer creates `feature/new-feature` branch
2. Makes commits and pushes
3. Creates PR to `develop`
4. Branch naming check runs and validates
5. After review and approval, PR merges to `develop`

### Staging Promotion

1. After merge to `develop`, `auto-promote-staging.yml` triggers
2. Checks for new commits in `develop` not in `staging`
3. Creates PR from `develop` to `staging`
4. `develop-to-staging-squash.yml` analyzes commits and comments on PR
5. After review and merge, `staging-deploy.yml` deploys to staging

### Production Deployment

1. Manual trigger of `auto-promote-production.yml`
2. Creates PR from `staging` to `main`
3. `staging-to-main-squash.yml` analyzes and comments on PR
4. After review and merge, `production-deploy.yml` deploys to production

## 🔧 Customization Options

### Branch Naming

Modify the regex in `branch-naming-check.yml` to support additional prefixes:

```yaml
# Current: ^(feature|bugfix|hotfix)/[a-z0-9\-]+$
# Add support for: ^(feature|bugfix|hotfix|chore|docs)/[a-z0-9\-]+$
```

### Deployment Scripts

Update the echo statements in deployment workflows with actual deployment commands:

```yaml
# Replace echo statements with actual deployment logic
- name: Deploy to Staging
  run: |
    # Your actual deployment script here
    ./deploy-staging.sh
```

### Approval Requirements

Modify branch protection rules to change approval requirements:

- Main: 2 approvals (production safety)
- Staging: 1 approval (faster QA cycles)
- Develop: 1 approval (development velocity)

## 🚨 Important Notes

### Security Considerations

- Branch protection rules prevent unauthorized changes
- Required status checks ensure quality gates
- Signed commits provide authenticity verification

### Rollback Strategy

- Single commit per release enables easy rollbacks
- Git tags provide release versioning
- Clean production history simplifies troubleshooting

### Team Adoption

- Start with less restrictive rules and tighten gradually
- Document the workflow for team members
- Provide training on the new processes

## 📞 Support and Troubleshooting

### Common Issues

1. **Workflow not triggering**: Check GitHub Actions permissions
2. **Branch protection blocking**: Verify approval requirements met
3. **Status checks failing**: Review workflow logs for errors

### Debugging Steps

1. Check GitHub Actions logs
2. Verify branch protection settings
3. Test with the provided testing script
4. Review workflow file syntax

---

**🎉 Congratulations!** You now have a complete industry-grade Git infrastructure setup. Follow the implementation checklist to configure GitHub settings and test the workflow.
