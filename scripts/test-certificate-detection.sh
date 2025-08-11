#!/bin/bash

# Test Certificate Detection Logic
# This script tests the same logic used in the GitHub Actions workflow

echo "🔍 Testing Certificate Detection Logic"
echo "====================================="
echo ""

# Check if running on macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Check what certificates are available in the keychain
echo "📋 Available certificates in keychain:"
AVAILABLE_CERTS=$(security find-identity -v -p codesigning 2>/dev/null || echo "")

if [ -z "$AVAILABLE_CERTS" ]; then
    echo "❌ No code signing certificates found"
    exit 1
fi

echo "$AVAILABLE_CERTS"
echo ""

# Test the detection logic
echo "🔍 Testing detection logic:"

if echo "$AVAILABLE_CERTS" | grep -q "Apple Development\|iPhone Developer"; then
    echo "✅ Development certificate detected"
    echo "   → Would use: Automatic code signing"
    echo "   → Export method: development"
    DETECTED_TYPE="development"
elif echo "$AVAILABLE_CERTS" | grep -q "Apple Distribution\|iPhone Distribution"; then
    echo "✅ Distribution certificate detected"
    echo "   → Would use: Manual code signing"
    echo "   → Export method: ad-hoc"
    DETECTED_TYPE="distribution"
else
    echo "❌ No suitable signing certificate found"
    echo "   Available certificates:"
    echo "$AVAILABLE_CERTS"
    exit 1
fi

echo ""
echo "📊 Summary:"
echo "Certificate type: $DETECTED_TYPE"

if [ "$DETECTED_TYPE" = "development" ]; then
    echo "✅ Perfect for GitHub Actions workflow!"
    echo "   The workflow will use automatic signing"
    echo "   No provisioning profile conflicts"
    echo "   IPA will work on registered devices"
else
    echo "✅ Great for production distribution!"
    echo "   The workflow will use manual signing"
    echo "   Requires matching provisioning profile"
    echo "   IPA will work on any device (ad-hoc)"
fi

echo ""
echo "🚀 Your certificate setup is compatible with the workflow!"
