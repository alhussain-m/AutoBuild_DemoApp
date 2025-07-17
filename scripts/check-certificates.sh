#!/bin/bash

# Certificate Validation Script for iOS CI/CD
# This script helps diagnose certificate and provisioning profile issues

set -e

echo "🔍 iOS Certificate & Provisioning Profile Checker"
echo "================================================="
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

# Check if running on macOS
if [ "$(uname)" != "Darwin" ]; then
    print_color $RED "❌ This script must be run on macOS"
    exit 1
fi

print_color $BLUE "📋 System Information:"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Xcode Version: $(xcodebuild -version | head -1)"
echo ""

print_color $BLUE "🔐 Checking Keychain Certificates:"
echo ""

# Check for signing certificates
CERTIFICATES=$(security find-identity -v -p codesigning 2>/dev/null || echo "")

if [ -z "$CERTIFICATES" ]; then
    print_color $RED "❌ No code signing certificates found in keychain"
    echo ""
    print_color $YELLOW "To fix this:"
    echo "1. Download your certificate from Apple Developer Portal"
    echo "2. Double-click to install in Keychain Access"
    echo "3. Or export from another Mac and import here"
    exit 1
else
    print_color $GREEN "✅ Code signing certificates found:"
    echo "$CERTIFICATES"
    echo ""
fi

# Check for iPhone Distribution certificate specifically
if echo "$CERTIFICATES" | grep -q "iPhone Distribution"; then
    print_color $GREEN "✅ iPhone Distribution certificate found"
    DIST_CERT=$(echo "$CERTIFICATES" | grep "iPhone Distribution" | head -1)
    print_color $BLUE "Distribution Certificate: $DIST_CERT"
else
    print_color $YELLOW "⚠️  iPhone Distribution certificate not found"
    echo ""
    print_color $YELLOW "Available certificates:"
    echo "$CERTIFICATES"
    echo ""
    print_color $YELLOW "For ad-hoc distribution, you need an 'iPhone Distribution' certificate"
    print_color $YELLOW "Not 'iPhone Developer' or 'Apple Development'"
fi

echo ""

# Check for team ID in certificates
print_color $BLUE "🏢 Checking Team ID (should be 8LE2DAQG25):"
if echo "$CERTIFICATES" | grep -q "8LE2DAQG25"; then
    print_color $GREEN "✅ Team ID 8LE2DAQG25 found in certificates"
else
    print_color $YELLOW "⚠️  Team ID 8LE2DAQG25 not found in certificate names"
    print_color $YELLOW "This might be normal - team ID may not appear in certificate name"
fi

echo ""

# Check provisioning profiles
print_color $BLUE "📱 Checking Provisioning Profiles:"
PROFILES_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"

if [ -d "$PROFILES_DIR" ]; then
    PROFILE_COUNT=$(find "$PROFILES_DIR" -name "*.mobileprovision" | wc -l)
    print_color $GREEN "✅ Provisioning profiles directory exists"
    echo "Profile count: $PROFILE_COUNT"
    
    if [ $PROFILE_COUNT -gt 0 ]; then
        echo ""
        print_color $BLUE "📋 Installed profiles:"
        for profile in "$PROFILES_DIR"/*.mobileprovision; do
            if [ -f "$profile" ]; then
                # Extract profile info
                PROFILE_NAME=$(security cms -D -i "$profile" 2>/dev/null | plutil -p - | grep '"Name"' | cut -d'"' -f4 2>/dev/null || echo "Unknown")
                BUNDLE_ID=$(security cms -D -i "$profile" 2>/dev/null | plutil -p - | grep -A1 '"application-identifier"' | tail -1 | cut -d'"' -f2 | cut -d'.' -f2- 2>/dev/null || echo "Unknown")
                TEAM_ID=$(security cms -D -i "$profile" 2>/dev/null | plutil -p - | grep '"TeamIdentifier"' -A1 | tail -1 | cut -d'"' -f2 2>/dev/null || echo "Unknown")
                
                echo "  • $PROFILE_NAME"
                echo "    Bundle ID: $BUNDLE_ID"
                echo "    Team ID: $TEAM_ID"
                
                # Check if this is the profile we need
                if [ "$BUNDLE_ID" = "com.citus.stage" ]; then
                    print_color $GREEN "    ✅ Matches required bundle ID!"
                    if [ "$TEAM_ID" = "8LE2DAQG25" ]; then
                        print_color $GREEN "    ✅ Matches required team ID!"
                    else
                        print_color $YELLOW "    ⚠️  Team ID doesn't match (expected: 8LE2DAQG25)"
                    fi
                fi
                echo ""
            fi
        done
    else
        print_color $YELLOW "⚠️  No provisioning profiles installed"
    fi
else
    print_color $YELLOW "⚠️  Provisioning profiles directory not found"
    echo "Creating directory: $PROFILES_DIR"
    mkdir -p "$PROFILES_DIR"
fi

echo ""

# Check for specific bundle ID profile
print_color $BLUE "🎯 Checking for com.citus.stage profile:"
FOUND_PROFILE=false

if [ -d "$PROFILES_DIR" ]; then
    for profile in "$PROFILES_DIR"/*.mobileprovision; do
        if [ -f "$profile" ]; then
            BUNDLE_ID=$(security cms -D -i "$profile" 2>/dev/null | plutil -p - | grep -A1 '"application-identifier"' | tail -1 | cut -d'"' -f2 | cut -d'.' -f2- 2>/dev/null || echo "")
            if [ "$BUNDLE_ID" = "com.citus.stage" ]; then
                FOUND_PROFILE=true
                PROFILE_NAME=$(security cms -D -i "$profile" 2>/dev/null | plutil -p - | grep '"Name"' | cut -d'"' -f4 2>/dev/null || echo "Unknown")
                print_color $GREEN "✅ Found profile for com.citus.stage: $PROFILE_NAME"
                break
            fi
        fi
    done
fi

if [ "$FOUND_PROFILE" = false ]; then
    print_color $RED "❌ No provisioning profile found for com.citus.stage"
    echo ""
    print_color $YELLOW "To fix this:"
    echo "1. Go to Apple Developer Portal"
    echo "2. Certificates, Identifiers & Profiles → Profiles"
    echo "3. Find or create profile for com.citus.stage"
    echo "4. Download the .mobileprovision file"
    echo "5. Double-click to install, or copy to:"
    echo "   $PROFILES_DIR"
fi

echo ""

# Summary and recommendations
print_color $BLUE "📊 Summary & Recommendations:"
echo ""

# Check certificate status
if echo "$CERTIFICATES" | grep -q "iPhone Distribution"; then
    print_color $GREEN "✅ Certificate: iPhone Distribution certificate available"
else
    print_color $RED "❌ Certificate: Need iPhone Distribution certificate"
    echo "   → Export from Apple Developer Portal or another Mac"
fi

# Check profile status
if [ "$FOUND_PROFILE" = true ]; then
    print_color $GREEN "✅ Profile: com.citus.stage provisioning profile available"
else
    print_color $RED "❌ Profile: Need provisioning profile for com.citus.stage"
    echo "   → Download from Apple Developer Portal"
fi

echo ""

# Generate secrets if everything looks good
if echo "$CERTIFICATES" | grep -q "iPhone Distribution" && [ "$FOUND_PROFILE" = true ]; then
    print_color $GREEN "🎉 All requirements met! Ready to generate GitHub secrets."
    echo ""
    print_color $BLUE "Next steps:"
    echo "1. Run: ./scripts/generate-secrets.sh"
    echo "2. Add the generated secrets to GitHub repository"
    echo "3. Run the iOS CI/CD workflow"
else
    print_color $YELLOW "⚠️  Some requirements missing. Fix the issues above first."
fi

echo ""
print_color $BLUE "🔧 Useful Commands:"
echo "• Check certificates: security find-identity -v -p codesigning"
echo "• List profiles: ls -la '$PROFILES_DIR'"
echo "• Generate secrets: ./scripts/generate-secrets.sh"
echo "• Validate setup: ./scripts/validate-setup.sh"

echo ""
print_color $BLUE "📚 Documentation:"
echo "• Setup Guide: CI_CD_SETUP.md"
echo "• Troubleshooting: TROUBLESHOOTING.md"
echo "• Apple Developer Portal: https://developer.apple.com"
