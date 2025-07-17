# 🔧 iOS CI/CD Troubleshooting Guide

## 🚨 Common Issues and Solutions

### 1. **Web Build Fails with Exit Code 3**

#### **Symptoms:**
- Build fails at "Build web app" step
- Error: `ng run app:build:qa6 exited with exit code 3`
- Angular CLI version compatibility errors

#### **Causes:**
- Node.js version incompatibility with Angular 20
- Missing or incorrect Angular configurations
- Standalone component configuration issues

#### **Solutions:**

##### **A. Node.js Version Issue**
```bash
# The workflow uses Node.js 20.x which is compatible
# Local testing might fail with newer Node.js versions

# For local testing, use Node.js 20.x:
nvm install 20
nvm use 20
npm install
npx ionic build --configuration=qa6
```

##### **B. Angular Configuration Issue**
The project uses Angular 20 with module-based components. Ensure components have `standalone: false`:

```typescript
// src/app/app.component.ts
@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
  standalone: false  // ← This is important
})
export class AppComponent { }
```

##### **C. Use Build Script**
The project includes a robust build script that handles fallbacks:
```bash
./scripts/build-web.sh qa6
```

### 2. **Code Signing Errors**

#### **Symptoms:**
- iOS build fails at code signing step
- Certificate or provisioning profile errors

#### **Solutions:**

##### **A. Verify GitHub Secrets**
Ensure all secrets are correctly set:
```bash
# Generate secrets using the helper script
./scripts/generate-secrets.sh

# Required secrets:
# - IOS_CERTIFICATE_BASE64
# - IOS_CERTIFICATE_PASSWORD  
# - IOS_PROVISIONING_PROFILE_BASE64
# - KEYCHAIN_PASSWORD
# - NPM_AUTH_TOKEN
```

##### **B. Certificate Issues**
```bash
# Check certificate validity (macOS only)
security find-identity -v -p codesigning

# Verify certificate is not expired
# Ensure it's a Distribution certificate for ad-hoc builds
```

##### **C. Provisioning Profile Issues**
- Ensure profile matches bundle ID: `com.citus.stage`
- Verify profile is for Distribution (not Development)
- Check profile hasn't expired

### 3. **IPA Not Generated**

#### **Symptoms:**
- Build completes but no IPA in artifacts
- Export step fails

#### **Solutions:**

##### **A. Check Archive Creation**
The workflow verifies archive creation. If this fails:
- Check code signing configuration
- Verify Xcode project settings
- Ensure all dependencies are installed

##### **B. Export Options**
The workflow uses ad-hoc distribution. Ensure:
- Provisioning profile supports ad-hoc distribution
- Certificate has proper permissions
- Team ID matches: `8LE2DAQG25`

### 4. **NPM Authentication Errors**

#### **Symptoms:**
- Dependency installation fails
- GitHub package registry errors

#### **Solutions:**

##### **A. Create GitHub Token**
```bash
# Go to GitHub → Settings → Developer settings → Personal access tokens
# Create token with 'read:packages' scope
# Add as NPM_AUTH_TOKEN secret
```

##### **B. Verify Package Access**
Ensure your GitHub token has access to `@citushealth-inc` packages.

### 5. **Environment Configuration Issues**

#### **Symptoms:**
- Wrong environment used in build
- Environment files not found

#### **Solutions:**

##### **A. Verify Environment Files**
```bash
# Check all environment files exist:
ls -la src/environments/
# Should show:
# - environment.ts
# - environment.qa6.ts
# - environment.qa7.ts
# - environment.prod.ts
```

##### **B. Check Angular Configuration**
```bash
# Verify configurations in angular.json:
grep -A 5 '"configurations"' angular.json
```

## 🛠️ Debugging Tools

### 1. **Validation Script**
```bash
./scripts/validate-setup.sh
```
Checks your local setup and identifies issues.

### 2. **Build Script**
```bash
./scripts/build-web.sh qa6
```
Tests web build with comprehensive fallbacks.

### 3. **Secrets Generator**
```bash
./scripts/generate-secrets.sh
```
Generates all required GitHub secrets.

## 📋 Pre-Flight Checklist

Before running the workflow, ensure:

- [ ] All GitHub secrets are set correctly
- [ ] Certificate is valid and not expired
- [ ] Provisioning profile matches bundle ID
- [ ] Environment files exist
- [ ] Angular configurations are correct
- [ ] NPM token has package access

## 🔍 Workflow Debugging

### Enable Verbose Logging
The workflow includes comprehensive logging. Check:

1. **Web Build Logs** - Shows Node.js versions and build attempts
2. **Code Signing Logs** - Validates certificates and profiles
3. **iOS Build Logs** - Shows Xcode build process
4. **Export Logs** - Detailed IPA creation process

### Common Log Messages

#### **Success Indicators:**
- `✅ Web build completed successfully!`
- `✅ Code signing setup completed`
- `✅ iOS archive completed successfully!`
- `✅ IPA export completed successfully!`

#### **Warning Indicators:**
- `⚠️ Configuration not found, using fallback`
- `⚠️ Certificate validation warnings`

#### **Error Indicators:**
- `❌ Build failed`
- `❌ Certificate file not created`
- `❌ IPA not found`

## 🚀 Quick Fixes

### For Immediate Build Success:

1. **Use Production Configuration:**
   ```yaml
   # In workflow dispatch, choose 'production' environment
   # This has the most stable configuration
   ```

2. **Verify Secrets Format:**
   ```bash
   # Ensure base64 secrets have no line breaks
   echo "YOUR_SECRET" | base64 --decode > test.p12
   # Should create valid file without errors
   ```

3. **Check Bundle ID:**
   ```bash
   # Ensure all configurations use: com.citus.stage
   grep -r "com.citus.stage" ios/App/
   ```

## 📞 Getting Help

### If Issues Persist:

1. **Check Workflow Logs** - Look for specific error messages
2. **Run Validation Script** - `./scripts/validate-setup.sh`
3. **Test Locally** - Use Node.js 20.x for local testing
4. **Verify Certificates** - Check expiration and permissions
5. **Review Configurations** - Ensure angular.json is correct

### Useful Commands:
```bash
# Test web build locally
./scripts/build-web.sh qa6

# Validate setup
./scripts/validate-setup.sh

# Generate fresh secrets
./scripts/generate-secrets.sh

# Check Node.js compatibility
node --version  # Should be 20.x for best compatibility
```

## 🎯 Success Indicators

When everything works correctly, you should see:

1. ✅ Web build completes in ~2-3 minutes
2. ✅ iOS build completes in ~10-15 minutes  
3. ✅ IPA artifact appears in workflow artifacts
4. ✅ File size is reasonable (typically 10-50MB)
5. ✅ IPA can be installed on devices

The workflow is designed to be robust with multiple fallbacks, so most issues are resolved automatically!
