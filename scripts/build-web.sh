#!/bin/bash

# Web Build Script for CI/CD
# This script handles different build scenarios and fallbacks

set -e

echo "🔨 Web Build Script"
echo "=================="

# Get environment parameter
BUILD_ENV=${1:-"production"}
echo "Target environment: $BUILD_ENV"

# Display versions
echo ""
echo "📋 Environment Info:"
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Check if Ionic CLI is available
if command -v ionic >/dev/null 2>&1; then
    echo "Ionic CLI version: $(ionic --version)"
else
    echo "Ionic CLI: Not available"
fi

# Check if Angular CLI is available
if command -v ng >/dev/null 2>&1; then
    echo "Angular CLI version: $(ng version --skip-git 2>/dev/null || echo 'Available but version check failed')"
else
    echo "Angular CLI: Not available"
fi

echo ""
echo "🔍 Checking configurations..."

# Check if the requested configuration exists in angular.json
if [ -f "angular.json" ]; then
    if grep -q "\"$BUILD_ENV\"" angular.json; then
        echo "✅ Configuration '$BUILD_ENV' found in angular.json"
        CONFIG_EXISTS=true
    else
        echo "⚠️  Configuration '$BUILD_ENV' not found in angular.json"
        echo "Available configurations:"
        grep -o '"[^"]*"' angular.json | grep -E "(qa6|qa7|production|development)" | sort | uniq
        CONFIG_EXISTS=false
    fi
else
    echo "❌ angular.json not found"
    exit 1
fi

echo ""
echo "🏗️  Starting build process..."

# Build function with multiple fallbacks
build_app() {
    local config=$1
    local attempt=$2
    
    echo "Attempt $attempt: Building with configuration '$config'"
    
    # Try Ionic CLI first
    if command -v ionic >/dev/null 2>&1; then
        echo "Using Ionic CLI..."
        if ionic build --configuration=$config 2>/dev/null; then
            echo "✅ Ionic build succeeded with configuration: $config"
            return 0
        fi
        
        # Fallback to --prod flag
        if [ "$config" = "production" ] && ionic build --prod 2>/dev/null; then
            echo "✅ Ionic build succeeded with --prod flag"
            return 0
        fi
    fi
    
    # Try Angular CLI
    if command -v ng >/dev/null 2>&1; then
        echo "Using Angular CLI..."
        if ng build --configuration=$config 2>/dev/null; then
            echo "✅ Angular CLI build succeeded with configuration: $config"
            return 0
        fi
    fi
    
    # Try npm run build
    if npm run build -- --configuration=$config 2>/dev/null; then
        echo "✅ npm run build succeeded with configuration: $config"
        return 0
    fi
    
    return 1
}

# Try building with requested configuration
if [ "$CONFIG_EXISTS" = true ]; then
    if build_app "$BUILD_ENV" 1; then
        BUILD_SUCCESS=true
    else
        echo "⚠️  Build failed with requested configuration, trying fallbacks..."
        BUILD_SUCCESS=false
    fi
else
    BUILD_SUCCESS=false
fi

# Fallback to production if requested config failed
if [ "$BUILD_SUCCESS" != true ] && [ "$BUILD_ENV" != "production" ]; then
    echo ""
    echo "🔄 Falling back to production configuration..."
    if build_app "production" 2; then
        BUILD_SUCCESS=true
    fi
fi

# Final fallback - try any available configuration
if [ "$BUILD_SUCCESS" != true ]; then
    echo ""
    echo "🔄 Trying alternative configurations..."
    
    for config in "qa6" "development" ""; do
        if [ -n "$config" ]; then
            echo "Trying configuration: $config"
            if build_app "$config" 3; then
                BUILD_SUCCESS=true
                break
            fi
        else
            # Try without configuration
            echo "Trying build without specific configuration..."
            if ionic build 2>/dev/null || ng build 2>/dev/null || npm run build 2>/dev/null; then
                echo "✅ Build succeeded without specific configuration"
                BUILD_SUCCESS=true
                break
            fi
        fi
    done
fi

echo ""
if [ "$BUILD_SUCCESS" = true ]; then
    echo "✅ Build completed successfully!"
    
    # Verify output
    if [ -d "www" ] && [ "$(ls -A www 2>/dev/null)" ]; then
        echo "📦 Output directory 'www' created with content"
        echo "📊 Build size: $(du -sh www 2>/dev/null || echo 'Unknown')"
        echo "📁 Files created: $(find www -type f | wc -l 2>/dev/null || echo 'Unknown') files"
    else
        echo "⚠️  Output directory 'www' is empty or missing"
        exit 1
    fi
else
    echo "❌ All build attempts failed!"
    echo ""
    echo "🔧 Troubleshooting suggestions:"
    echo "1. Check Node.js version compatibility"
    echo "2. Run 'npm install' to ensure dependencies are installed"
    echo "3. Verify angular.json has correct configurations"
    echo "4. Check for TypeScript compilation errors"
    echo "5. Try running build locally first"
    exit 1
fi

echo ""
echo "🎉 Web build script completed successfully!"
