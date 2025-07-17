#!/bin/bash

# iOS CI/CD Setup Validator
# This script validates your local setup before running CI/CD

set -e

echo "🔍 iOS CI/CD Setup Validator"
echo "============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Counters
PASSED=0
FAILED=0

# Function to check and report
check_item() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    printf "%-50s" "$description"
    
    if eval "$command" >/dev/null 2>&1; then
        print_color $GREEN "✅ PASS"
        ((PASSED++))
    else
        print_color $RED "❌ FAIL"
        ((FAILED++))
        if [ ! -z "$expected" ]; then
            print_color $YELLOW "   Expected: $expected"
        fi
    fi
}

print_color $BLUE "Checking project structure..."
echo ""

# Check project files
check_item "package.json exists" "[ -f package.json ]"
check_item "ionic.config.json exists" "[ -f ionic.config.json ]"
check_item "angular.json exists" "[ -f angular.json ]"
check_item "capacitor.config.ts exists" "[ -f capacitor.config.ts ]"
check_item "iOS project exists" "[ -d ios/App ]"
check_item "Workflow file exists" "[ -f .github/workflows/qa6_iOS_Build.yml ]"

echo ""
print_color $BLUE "Checking environment files..."
echo ""

check_item "Default environment" "[ -f src/environments/environment.ts ]"
check_item "QA6 environment" "[ -f src/environments/environment.qa6.ts ]"
check_item "QA7 environment" "[ -f src/environments/environment.qa7.ts ]"
check_item "Production environment" "[ -f src/environments/environment.prod.ts ]"

echo ""
print_color $BLUE "Checking Node.js setup..."
echo ""

check_item "Node.js installed" "command -v node"
check_item "npm installed" "command -v npm"
check_item "Node version >= 18" "node -v | grep -E 'v1[8-9]|v[2-9][0-9]'"

echo ""
print_color $BLUE "Checking dependencies..."
echo ""

check_item "node_modules exists" "[ -d node_modules ]"
check_item "@ionic/cli available" "command -v ionic || npm list -g @ionic/cli"
check_item "@capacitor/cli available" "command -v cap || npm list @capacitor/cli"

echo ""
print_color $BLUE "Checking Angular configurations..."
echo ""

check_item "QA6 config in angular.json" "grep -q '\"qa6\"' angular.json"
check_item "QA7 config in angular.json" "grep -q '\"qa7\"' angular.json"
check_item "Production config in angular.json" "grep -q '\"production\"' angular.json"

echo ""
print_color $BLUE "Checking iOS setup..."
echo ""

if [ "$(uname)" = "Darwin" ]; then
    check_item "Xcode installed" "command -v xcodebuild"
    check_item "CocoaPods installed" "command -v pod"
    check_item "iOS workspace exists" "[ -f ios/App/App.xcworkspace ]"
    check_item "Podfile exists" "[ -f ios/App/Podfile ]"
else
    print_color $YELLOW "Skipping iOS checks (not on macOS)"
fi

echo ""
print_color $BLUE "Testing builds..."
echo ""

# Test web build
printf "%-50s" "Web build (qa6)"
if ionic build --configuration=qa6 >/dev/null 2>&1; then
    print_color $GREEN "✅ PASS"
    ((PASSED++))
else
    print_color $RED "❌ FAIL"
    ((FAILED++))
fi

printf "%-50s" "www directory created"
if [ -d www ] && [ "$(ls -A www)" ]; then
    print_color $GREEN "✅ PASS"
    ((PASSED++))
else
    print_color $RED "❌ FAIL"
    ((FAILED++))
fi

echo ""
print_color $BLUE "Checking workflow configuration..."
echo ""

# Check workflow file content
WORKFLOW_FILE=".github/workflows/qa6_iOS_Build.yml"
if [ -f "$WORKFLOW_FILE" ]; then
    check_item "Correct bundle ID" "grep -q 'com.citus.stage' $WORKFLOW_FILE"
    check_item "Correct team ID" "grep -q '8LE2DAQG25' $WORKFLOW_FILE"
    check_item "Uses correct Node version" "grep -q '18.x' $WORKFLOW_FILE"
    check_item "Has required secrets" "grep -q 'IOS_CERTIFICATE_BASE64' $WORKFLOW_FILE"
fi

echo ""
print_color $BLUE "Summary"
echo "======="
print_color $GREEN "Passed: $PASSED"
print_color $RED "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    print_color $GREEN "🎉 All checks passed! Your setup is ready for CI/CD."
    echo ""
    print_color $BLUE "Next steps:"
    echo "1. Add required secrets to GitHub repository"
    echo "2. Push code to trigger the workflow"
    echo "3. Monitor the build in GitHub Actions"
else
    print_color $RED "⚠️  Some checks failed. Please fix the issues above."
    echo ""
    print_color $YELLOW "Common fixes:"
    echo "• Run 'npm install' to install dependencies"
    echo "• Run 'ionic build --configuration=qa6' to test build"
    echo "• Check environment files exist in src/environments/"
    echo "• Verify angular.json has correct configurations"
fi

echo ""
print_color $BLUE "For help, see: CI_CD_SETUP.md"
