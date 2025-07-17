#!/bin/bash

# iOS CI/CD Secrets Generator
# This script helps generate the required base64 encoded secrets for GitHub Actions

set -e

echo "🔐 iOS CI/CD Secrets Generator"
echo "================================"
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

print_color $BLUE "This script will help you generate the required secrets for iOS CI/CD pipeline."
echo ""

# Check if required files exist
CERT_FILE=""
PROFILE_FILE=""

print_color $YELLOW "Step 1: Certificate (.p12 file)"
echo "Please provide the path to your .p12 certificate file:"
read -p "Certificate path: " CERT_PATH

if [ -f "$CERT_PATH" ]; then
    CERT_FILE="$CERT_PATH"
    print_color $GREEN "✅ Certificate file found: $CERT_FILE"
else
    print_color $RED "❌ Certificate file not found: $CERT_PATH"
    echo ""
    print_color $YELLOW "How to export certificate:"
    echo "1. Open Keychain Access"
    echo "2. Find your iPhone Developer/Distribution certificate"
    echo "3. Right-click → Export"
    echo "4. Choose Personal Information Exchange (.p12)"
    echo "5. Set a password and save"
    exit 1
fi

echo ""
print_color $YELLOW "Step 2: Certificate Password"
echo "Enter the password you set when exporting the .p12 certificate:"
read -s -p "Certificate password: " CERT_PASSWORD
echo ""

if [ -z "$CERT_PASSWORD" ]; then
    print_color $RED "❌ Certificate password cannot be empty"
    exit 1
fi

echo ""
print_color $YELLOW "Step 3: Provisioning Profile (.mobileprovision file)"
echo "Please provide the path to your .mobileprovision file:"
read -p "Provisioning profile path: " PROFILE_PATH

if [ -f "$PROFILE_PATH" ]; then
    PROFILE_FILE="$PROFILE_PATH"
    print_color $GREEN "✅ Provisioning profile found: $PROFILE_FILE"
else
    print_color $RED "❌ Provisioning profile not found: $PROFILE_PATH"
    echo ""
    print_color $YELLOW "How to get provisioning profile:"
    echo "1. Go to Apple Developer Portal"
    echo "2. Certificates, Identifiers & Profiles → Profiles"
    echo "3. Download your app's provisioning profile"
    echo "4. Or find in ~/Library/MobileDevice/Provisioning Profiles/"
    exit 1
fi

echo ""
print_color $YELLOW "Step 4: Keychain Password"
echo "Enter a secure password for the temporary keychain (any password):"
read -s -p "Keychain password: " KEYCHAIN_PASSWORD
echo ""

if [ -z "$KEYCHAIN_PASSWORD" ]; then
    print_color $RED "❌ Keychain password cannot be empty"
    exit 1
fi

echo ""
print_color $BLUE "Generating base64 encoded secrets..."
echo ""

# Generate base64 for certificate
CERT_BASE64=$(base64 -i "$CERT_FILE")
if [ $? -eq 0 ]; then
    print_color $GREEN "✅ Certificate base64 generated"
else
    print_color $RED "❌ Failed to generate certificate base64"
    exit 1
fi

# Generate base64 for provisioning profile
PROFILE_BASE64=$(base64 -i "$PROFILE_FILE")
if [ $? -eq 0 ]; then
    print_color $GREEN "✅ Provisioning profile base64 generated"
else
    print_color $RED "❌ Failed to generate provisioning profile base64"
    exit 1
fi

echo ""
print_color $GREEN "🎉 All secrets generated successfully!"
echo ""

# Create output file
OUTPUT_FILE="github-secrets.txt"
cat > "$OUTPUT_FILE" << EOF
# GitHub Secrets for iOS CI/CD Pipeline
# Copy these values to your GitHub repository secrets
# Go to: Settings → Secrets and variables → Actions → New repository secret

IOS_CERTIFICATE_BASE64:
$CERT_BASE64

IOS_CERTIFICATE_PASSWORD:
$CERT_PASSWORD

IOS_PROVISIONING_PROFILE_BASE64:
$PROFILE_BASE64

KEYCHAIN_PASSWORD:
$KEYCHAIN_PASSWORD

# Additional required secret (create manually):
# NPM_AUTH_TOKEN: Your GitHub Personal Access Token with 'read:packages' scope

# Instructions:
# 1. Copy each value above (without the secret name)
# 2. Create a new secret in GitHub with the exact name
# 3. Paste the corresponding value
# 4. Make sure there are no extra spaces or line breaks

EOF

print_color $BLUE "📄 Secrets saved to: $OUTPUT_FILE"
echo ""

print_color $YELLOW "Next Steps:"
echo "1. Open your GitHub repository"
echo "2. Go to Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Add each secret using the names and values from $OUTPUT_FILE"
echo "5. Create NPM_AUTH_TOKEN manually (GitHub Personal Access Token)"
echo ""

print_color $BLUE "Required GitHub Secrets:"
echo "• IOS_CERTIFICATE_BASE64"
echo "• IOS_CERTIFICATE_PASSWORD"
echo "• IOS_PROVISIONING_PROFILE_BASE64"
echo "• KEYCHAIN_PASSWORD"
echo "• NPM_AUTH_TOKEN (create manually)"
echo ""

print_color $GREEN "✅ Setup complete! Your iOS CI/CD pipeline is ready to use."

# Security note
echo ""
print_color $RED "🔒 SECURITY NOTE:"
print_color $RED "The file $OUTPUT_FILE contains sensitive information."
print_color $RED "Delete it after adding secrets to GitHub:"
print_color $RED "rm $OUTPUT_FILE"
