# iOS CI/CD Pipeline Setup Guide

## 🚀 Overview
This guide explains how to set up the iOS CI/CD pipeline using GitHub Actions to automatically build and generate IPA files.

## 📋 Prerequisites

### 1. Apple Developer Account
- Active Apple Developer Program membership
- Development/Distribution certificate
- Provisioning profile for your app

### 2. Required Files
- `.p12` certificate file (exported from Keychain Access)
- `.mobileprovision` provisioning profile file

## 🔐 GitHub Secrets Setup

### Required Secrets
Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description | How to Generate |
|-------------|-------------|-----------------|
| `IOS_CERTIFICATE_BASE64` | Base64 encoded .p12 certificate | `base64 -i YourCert.p12 \| pbcopy` |
| `IOS_CERTIFICATE_PASSWORD` | Password for .p12 certificate | The password you set when exporting |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 encoded .mobileprovision | `base64 -i YourProfile.mobileprovision \| pbcopy` |
| `KEYCHAIN_PASSWORD` | Temporary keychain password | Any secure password (e.g., `TempKeychain123!`) |
| `NPM_AUTH_TOKEN` | GitHub package registry token | GitHub Personal Access Token |

### Step-by-Step Secret Generation

#### 1. Export Certificate (.p12)
```bash
# In Keychain Access:
# 1. Find your certificate (iPhone Developer/Distribution)
# 2. Right-click → Export
# 3. Choose .p12 format
# 4. Set a password
# 5. Save as YourCert.p12

# Generate base64:
base64 -i YourCert.p12 | pbcopy
```

#### 2. Get Provisioning Profile (.mobileprovision)
```bash
# Download from Apple Developer Portal or find in:
# ~/Library/MobileDevice/Provisioning Profiles/

# Generate base64:
base64 -i YourProfile.mobileprovision | pbcopy
```

#### 3. Create GitHub Token
```bash
# Go to GitHub → Settings → Developer settings → Personal access tokens
# Create token with 'read:packages' scope
```

## 🏗️ Workflow Configuration

### Current Setup
- **File**: `.github/workflows/qa6_iOS_Build.yml`
- **Triggers**: Push to `main`, `qa6`, `stage` branches or manual dispatch
- **Environments**: `qa6`, `qa7`, `production`

### Build Process
1. **Web Build** (Ubuntu)
   - Install dependencies
   - Build Ionic app with environment-specific configuration
   - Upload web build as artifact

2. **iOS Build** (macOS)
   - Download web build
   - Setup Xcode and CocoaPods
   - Configure code signing
   - Build and archive iOS app
   - Export IPA file
   - Upload IPA as GitHub artifact

## 📱 App Configuration

### Bundle ID & Team
- **Bundle ID**: `com.citus.stage`
- **Team ID**: `8LE2DAQG25`
- **Provisioning Profile**: `CitusHealth Stage Provisioning`

### Environment Files
- `src/environments/environment.ts` (default)
- `src/environments/environment.qa6.ts`
- `src/environments/environment.qa7.ts`
- `src/environments/environment.prod.ts`

## 🚀 Usage

### Automatic Builds
- Push to `qa6` branch → Builds with qa6 environment
- Push to `main` branch → Builds with production environment

### Manual Builds
1. Go to Actions tab in GitHub
2. Select "iOS Build & Generate IPA"
3. Click "Run workflow"
4. Choose environment (qa6, qa7, production)
5. Click "Run workflow"

### Download IPA
1. Go to completed workflow run
2. Scroll to "Artifacts" section
3. Download the IPA file
4. File available for 30 days

## 📲 Installation Options

### Option 1: Apple Configurator 2
1. Install Apple Configurator 2
2. Connect device
3. Drag IPA to device

### Option 2: Xcode Devices
1. Open Xcode → Window → Devices and Simulators
2. Select device
3. Drag IPA to "Installed Apps"

### Option 3: TestFlight (Manual)
1. Upload IPA to App Store Connect
2. Add to TestFlight
3. Distribute to testers

## 🔧 Troubleshooting

### Common Issues

#### 1. Code Signing Errors
- Verify certificate is valid and not expired
- Ensure provisioning profile matches bundle ID
- Check team ID matches certificate

#### 2. Build Failures
- Check all GitHub secrets are set correctly
- Verify base64 encoding is correct (no line breaks)
- Ensure certificate password is correct

#### 3. Web Build Errors
- Check NPM_AUTH_TOKEN is valid
- Verify environment files exist
- Check Angular configuration in `angular.json`

### Debug Steps
1. Check workflow logs for specific errors
2. Verify secrets are not empty
3. Test certificate/profile locally first
4. Check Apple Developer Portal for certificate status

## 📊 Build Artifacts

### Generated Files
- **Web Build**: `web-build-{environment}` (7 days retention)
- **iOS IPA**: `📱-iOS-App-{environment}-Build-{number}` (30 days retention)

### File Locations
- Web build: `www/` directory
- iOS archive: `$RUNNER_TEMP/App.xcarchive`
- IPA export: `$RUNNER_TEMP/export/*.ipa`

## 🔄 Workflow Customization

### Change Bundle ID
Update in `.github/workflows/qa6_iOS_Build.yml`:
```yaml
env:
  BUNDLE_ID: 'your.new.bundle.id'
```

### Add New Environment
1. Create `src/environments/environment.newenv.ts`
2. Add configuration to `angular.json`
3. Update workflow choices

### Modify Retention
Change `retention-days` in upload-artifact steps:
```yaml
- uses: actions/upload-artifact@v4
  with:
    retention-days: 60  # Change from 30 to 60 days
```

## 📞 Support

### Resources
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Ionic Documentation](https://ionicframework.com/docs)

### Common Commands
```bash
# Test build locally
ionic build --configuration=qa6
npx cap sync ios

# Check certificates
security find-identity -v -p codesigning

# List provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```
