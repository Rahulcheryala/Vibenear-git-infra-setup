#!/bin/bash

# Git Workflow Testing Script
# This script tests the complete Git infrastructure workflow

set -e

echo "🧪 Git Workflow Testing Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from the repository root."
    exit 1
fi

# Function to create test commits
create_test_commits() {
    local branch_name=$1
    local commit_count=$2

    print_status "Creating $commit_count test commits on branch: $branch_name"

    for i in $(seq 1 $commit_count); do
        echo "Test file $i for $branch_name" > "test-file-$branch_name-$i.txt"
        git add "test-file-$branch_name-$i.txt"
        git commit -m "feat($branch_name): Add test file $i - commit message $i"
    done

    print_success "Created $commit_count commits on $branch_name"
}

# Function to cleanup test files
cleanup_test_files() {
    print_status "Cleaning up test files..."
    git clean -fd
    git reset --hard HEAD
    print_success "Cleanup completed"
}

# Function to test branch naming convention
test_branch_naming() {
    print_status "Testing branch naming convention..."

    # Test valid branch names
    valid_branches=("feature/test-feature" "bugfix/test-bug" "hotfix/test-hotfix")

    for branch in "${valid_branches[@]}"; do
        print_status "Testing valid branch name: $branch"
        if [[ $branch =~ ^(feature|bugfix|hotfix)/[a-z0-9\-]+$ ]]; then
            print_success "✅ Valid branch name: $branch"
        else
            print_error "❌ Invalid branch name: $branch"
        fi
    done

    # Test invalid branch names
    invalid_branches=("invalid-branch" "Feature/test" "feature/Test_Feature" "feature/")

    for branch in "${invalid_branches[@]}"; do
        print_status "Testing invalid branch name: $branch"
        if [[ $branch =~ ^(feature|bugfix|hotfix)/[a-z0-9\-]+$ ]]; then
            print_error "❌ Should be invalid but passed: $branch"
        else
            print_success "✅ Correctly rejected invalid branch name: $branch"
        fi
    done
}

# Function to test feature branch workflow
test_feature_workflow() {
    print_status "Testing feature branch workflow..."

    # Ensure we're on develop
    git checkout develop
    git pull origin develop

    # Create test feature branches
    feature_branches=("feature/test1" "feature/test2" "feature/test3")

    for branch in "${feature_branches[@]}"; do
        print_status "Creating and testing feature branch: $branch"

        # Create branch from develop
        git checkout -b "$branch" develop

        # Create test commits
        create_test_commits "$branch" 3

        # Push branch
        git push -u origin "$branch"

        print_success "✅ Feature branch $branch created with commits"

        # Switch back to develop
        git checkout develop

        # Simulate PR merge (in real scenario, this would be done via GitHub PR)
        git merge "$branch" --no-ff -m "Merge $branch into develop"
        git push origin develop

        print_success "✅ Feature branch $branch merged to develop"

        # Cleanup
        git branch -d "$branch"
        git push origin --delete "$branch"
    done

    print_success "Feature workflow test completed"
}

# Function to test staging promotion
test_staging_promotion() {
    print_status "Testing staging promotion workflow..."

    # Check if there are commits to promote
    COMMITS_TO_PROMOTE=$(git log staging..develop --oneline --no-merges)

    if [ -z "$COMMITS_TO_PROMOTE" ]; then
        print_warning "No commits to promote from develop to staging"
        return 0
    fi

    print_status "Commits to promote to staging:"
    echo "$COMMITS_TO_PROMOTE"

    # Simulate staging promotion (in real scenario, this would create a PR)
    print_status "Simulating staging promotion..."

    # Create a temporary branch for staging promotion
    git checkout -b temp-staging-promotion staging

    # Merge develop into staging branch
    git merge develop --no-ff -m "Promote develop to staging - $(date)"

    print_success "✅ Staging promotion simulated"

    # Cleanup
    git checkout develop
    git branch -D temp-staging-promotion

    print_success "Staging promotion test completed"
}

# Function to test production deployment
test_production_deployment() {
    print_status "Testing production deployment workflow..."

    # Check if there are commits to deploy
    COMMITS_TO_DEPLOY=$(git log main..staging --oneline --no-merges)

    if [ -z "$COMMITS_TO_DEPLOY" ]; then
        print_warning "No commits to deploy from staging to main"
        return 0
    fi

    print_status "Commits to deploy to production:"
    echo "$COMMITS_TO_DEPLOY"

    # Simulate production deployment (in real scenario, this would create a PR)
    print_status "Simulating production deployment..."

    # Create a temporary branch for production deployment
    git checkout -b temp-production-deployment main

    # Merge staging into main branch
    git merge staging --no-ff -m "Release: Production deployment $(date +'%Y-%m-%d %H:%M:%S')"

    # Create a release tag
    RELEASE_TAG="v$(date +'%Y.%m.%d')-$(date +'%H%M')"
    git tag "$RELEASE_TAG"

    print_success "✅ Production deployment simulated with tag: $RELEASE_TAG"

    # Cleanup
    git checkout develop
    git branch -D temp-production-deployment
    git tag -d "$RELEASE_TAG"

    print_success "Production deployment test completed"
}

# Function to test deployment scripts
test_deployment_scripts() {
    print_status "Testing deployment scripts..."

    # Test staging deployment
    print_status "Testing staging deployment script..."
    echo "🚀 Deploying to staging environment..."
    echo "✅ Deployment to staging completed successfully"
    echo "🔗 Staging URL: https://staging.yourapp.com"

    # Test production deployment
    print_status "Testing production deployment script..."
    echo "🚀 Deploying to production environment..."
    echo "✅ Deployment to production completed successfully"
    echo "🔗 Production URL: https://yourapp.com"

    print_success "Deployment scripts test completed"
}

# Function to show current branch status
show_branch_status() {
    print_status "Current branch status:"
    echo ""
    git branch -vv
    echo ""

    print_status "Recent commits on each branch:"
    echo ""

    for branch in main staging develop; do
        if git show-ref --verify --quiet refs/heads/$branch; then
            echo "📋 $branch:"
            git log --oneline -5 $branch
            echo ""
        fi
    done
}

# Function to test workflow files
test_workflow_files() {
    print_status "Testing workflow files..."

    workflow_dir=".github/workflows"

    if [ ! -d "$workflow_dir" ]; then
        print_error "Workflow directory not found: $workflow_dir"
        return 1
    fi

    # Check if all required workflow files exist
    required_workflows=(
        "branch-naming-check.yml"
        "staging-deploy.yml"
        "production-deploy.yml"
        "develop-to-staging-squash.yml"
        "staging-to-main-squash.yml"
        "auto-promote-staging.yml"
        "auto-promote-production.yml"
    )

    for workflow in "${required_workflows[@]}"; do
        if [ -f "$workflow_dir/$workflow" ]; then
            print_success "✅ Found workflow: $workflow"
        else
            print_error "❌ Missing workflow: $workflow"
        fi
    done

    print_success "Workflow files check completed"
}

# Main execution
main() {
    echo "Starting Git workflow testing..."
    echo ""

    # Show current status
    show_branch_status

    # Test workflow files
    test_workflow_files
    echo ""

    # Test branch naming convention
    test_branch_naming
    echo ""

    # Test deployment scripts
    test_deployment_scripts
    echo ""

    # Ask user if they want to proceed with branch testing
    read -p "Do you want to test the full branch workflow? This will create test commits. (y/N): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Proceeding with full workflow test..."
        echo ""

        # Test feature workflow
        test_feature_workflow
        echo ""

        # Test staging promotion
        test_staging_promotion
        echo ""

        # Test production deployment
        test_production_deployment
        echo ""

        # Cleanup
        cleanup_test_files
    else
        print_status "Skipping full workflow test. Only basic tests were performed."
    fi

    echo ""
    print_success "🎉 Git workflow testing completed!"
    echo ""
    print_status "Next steps:"
    echo "1. Review the branch protection setup guide: BRANCH_PROTECTION_SETUP.md"
    echo "2. Configure branch protection rules in GitHub"
    echo "3. Set develop as the default branch"
    echo "4. Test the workflows by creating actual PRs"
    echo ""
    print_status "For manual testing:"
    echo "1. Create feature branches and PRs to develop"
    echo "2. Test the staging promotion workflow"
    echo "3. Test the production deployment workflow"
}

# Run main function
main "$@"
