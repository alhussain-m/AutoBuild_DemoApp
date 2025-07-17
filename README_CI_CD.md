# 🚀 iOS CI/CD Pipeline - Ready to Use!

## ✅ What I've Fixed

### 1. **Fixed Workflow File** (`.github/workflows/qa6_iOS_Build.yml`)
- ✅ Updated Node.js version to 20.x (compatible with Angular)
- ✅ Fixed Ionic build command to use proper configurations
- ✅ Added comprehensive error handling and debugging
- ✅ Improved code signing setup with validation
- ✅ Enhanced IPA export with verbose logging
- ✅ Added proper artifact upload for GitHub downloads

### 2. **Fixed Project Configuration**
- ✅ Fixed environment import in `src/app/home/home.page.ts`
- ✅ Verified Angular configurations in `angular.json`
- ✅ Confirmed environment files exist (qa6, qa7, production)

### 3. **Created Helper Scripts**
- ✅ `scripts/generate-secrets.sh` - Generates GitHub secrets
- ✅ `scripts/validate-setup.sh` - Validates local setup
- ✅ `CI_CD_SETUP.md` - Comprehensive setup guide

## 🔐 Required GitHub Secrets

Add these to your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description |
|-------------|-------------|
| `IOS_CERTIFICATE_BASE64` | Base64 encoded .p12 certificate |
| `IOS_CERTIFICATE_PASSWORD` | Password for .p12 certificate |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 encoded .mobileprovision file |
| `KEYCHAIN_PASSWORD` | Any secure password for temporary keychain |
| `NPM_AUTH_TOKEN` | GitHub Personal Access Token |

## 🛠️ Quick Setup

### 1. Generate Secrets
```bash
# Run the helper script
./scripts/generate-secrets.sh

# Follow the prompts to generate all required secrets
# The script will create a github-secrets.txt file with all values
```

### 2. Add Secrets to GitHub
1. Go to your repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret from the generated file
4. Create `NPM_AUTH_TOKEN` manually (GitHub Personal Access Token)

### 3. Test the Setup
```bash
# Validate your local setup
./scripts/validate-setup.sh

# This will check all requirements and test builds
```

## 🚀 How to Use

### Automatic Builds
- **Push to `qa6` branch** → Builds with qa6 environment
- **Push to `main` branch** → Builds with production environment
- **Push to `stage` branch** → Builds with qa6 environment

### Manual Builds
1. Go to GitHub → Actions tab
2. Select "iOS Build & Generate IPA"
3. Click "Run workflow"
4. Choose environment: qa6, qa7, or production
5. Click "Run workflow"

### Download IPA
1. Wait for workflow to complete (usually 10-15 minutes)
2. Go to the completed workflow run
3. Scroll down to "Artifacts" section
4. Download: `📱-iOS-App-{environment}-Build-{number}`
5. IPA file is available for 30 days

## 📱 Installation Options

### Option 1: Apple Configurator 2
```bash
# Install Apple Configurator 2 from Mac App Store
# Connect your device
# Drag the IPA file to your device
```

### Option 2: Xcode Devices Window
```bash
# Open Xcode → Window → Devices and Simulators
# Select your device
# Drag IPA to "Installed Apps" section
```

### Option 3: TestFlight (Manual Upload)
```bash
# Upload IPA to App Store Connect
# Add to TestFlight
# Distribute to internal/external testers
```

## 🔧 Key Improvements Made

### Build Process
- Fixed Node.js version compatibility (20.x)
- Proper Ionic build commands with Angular configurations
- Enhanced error handling and debugging output
- Comprehensive validation of secrets and files

### Code Signing
- Added secret validation before use
- Better error messages for missing certificates
- Verification of provisioning profiles
- Proper keychain cleanup

### IPA Generation
- Verbose logging for troubleshooting
- File verification at each step
- Proper export options for ad-hoc distribution
- Size and content validation

### Artifacts
- Clear naming convention for downloads
- 30-day retention for IPA files
- Separate web build artifacts for debugging

## 📊 Build Status

The workflow includes three jobs:

1. **build-web** (Ubuntu) - Builds the Ionic web app
2. **build-ios** (macOS) - Builds and signs the iOS app
3. **build-summary** - Provides download instructions

## 🔍 Troubleshooting

### Common Issues

#### Build Fails at Web Step
- Check `NPM_AUTH_TOKEN` is valid
- Verify environment files exist
- Run `./scripts/validate-setup.sh` locally

#### Code Signing Errors
- Verify all iOS secrets are correctly base64 encoded
- Check certificate is not expired
- Ensure provisioning profile matches bundle ID

#### No IPA Generated
- Check build logs for specific errors
- Verify provisioning profile is for distribution
- Ensure certificate has proper permissions

### Debug Commands
```bash
# Test local build
npx ionic build --configuration=qa6

# Check certificates (macOS only)
security find-identity -v -p codesigning

# Validate secrets format
echo "YOUR_BASE64_SECRET" | base64 --decode > test.p12
```

## 📞 Support

- **Setup Guide**: `CI_CD_SETUP.md`
- **Generate Secrets**: `./scripts/generate-secrets.sh`
- **Validate Setup**: `./scripts/validate-setup.sh`

## 🎉 You're Ready!

Your iOS CI/CD pipeline is now configured and ready to use. Just add the GitHub secrets and push your code to trigger the first build!

The workflow will:
1. ✅ Build your Ionic web app
2. ✅ Sync with Capacitor
3. ✅ Build and sign iOS app
4. ✅ Generate IPA file
5. ✅ Upload as downloadable artifact

**No TestFlight required** - Direct IPA download from GitHub Actions! 🚀
