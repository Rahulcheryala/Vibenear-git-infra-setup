#!/bin/bash

echo "🏗️ Setting up Git branching structure..."

# Ensure we're on main
git checkout main
git pull origin main

# Create and push develop branch from main
echo "📝 Creating develop branch..."
git checkout -b develop
git push -u origin develop

# Create and push staging branch from main
echo "📝 Creating staging branch..."
git checkout main
git checkout -b staging
git push -u origin staging

# Switch back to main
git checkout main

echo "✅ Branch structure created:"
echo "   main (Production)"
echo "   ├── staging (QA Testing)"
echo "   └── develop (Integration)"
echo ""
echo "🔧 Next steps:"
echo "1. Configure branch protection rules in GitHub"
echo "2. Set up required status checks"
echo "3. Configure merge settings (squash for develop, merge for staging/main)"