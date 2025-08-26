# Google OAuth Setup Guide for Time Reservation App

## 📋 Prerequisites
- Google Account
- Access to Google Cloud Console

## 🚀 Step-by-Step Setup

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **"Select a project"** → **"New Project"**
3. Enter project name: `time-reservation-auth`
4. Click **"Create"**

### 2. Enable Required APIs
1. Navigate to **"APIs & Services"** → **"Library"**
2. Search and enable these APIs:
   - **Google+ API** (for user profile)
   - **People API** (alternative to Google+)

### 3. Configure OAuth Consent Screen
1. Go to **"APIs & Services"** → **"OAuth consent screen"**
2. Choose **"External"** (for testing with any Google account)
3. Fill required information:
   ```
   App name: Time Reservation App
   User support email: your-email@example.com
   Developer contact: your-email@example.com
   ```
4. **Scopes**: Add the following scopes:
   - `email`
   - `profile`
   - `openid`
5. **Test users**: Add your email and any other test emails
6. Save and continue through all steps

### 4. Create OAuth 2.0 Credentials

#### Backend Web Credentials
1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"+ Create Credentials"** → **"OAuth 2.0 Client IDs"**
3. Application type: **"Web application"**
4. Name: `Time Reservation Backend`
5. **Authorized redirect URIs**:
   ```
   http://localhost:3000/google/callback
   http://192.168.0.199:3000/google/callback
   https://your-production-domain.com/google/callback
   ```
6. Click **"Create"**
7. **Copy the Client ID and Client Secret** - you'll need these!

#### Mobile Credentials (Flutter)

**For iOS:**
1. Create new OAuth 2.0 Client ID
2. Application type: **"iOS"**
3. Name: `Time Reservation iOS`
4. Bundle ID: `com.example.timeReservation` (match your iOS bundle ID)

**For Android:**
1. Create new OAuth 2.0 Client ID
2. Application type: **"Android"**
3. Name: `Time Reservation Android`
4. Package name: `com.example.time_reservation`
5. SHA-1 certificate fingerprint: 
   ```bash
   # Get debug SHA-1 (for development)
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

### 5. Update Your Configuration

#### Backend Environment Variables
Update your `docker-compose.yml` or `.env` file:
```yaml
GOOGLE_CLIENT_ID=your_actual_client_id_here
GOOGLE_CLIENT_SECRET=your_actual_client_secret_here
GOOGLE_CALLBACK_URL=http://localhost:3000/google/callback
```

#### Flutter Configuration
Update your Flutter app's Google Sign-In configuration:

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<meta-data
    android:name="com.google.android.gms.auth.api.signin.ClientId"
    android:value="YOUR_WEB_CLIENT_ID" />
```

### 6. Testing Your Setup

#### Test Backend OAuth Flow
1. Start your backend: `docker compose up -d`
2. Visit: `http://localhost:3000/google`
3. Should redirect to Google OAuth consent screen

#### Test Mobile Integration
1. Use the `/google/token` endpoint to verify mobile tokens
2. Test with your Google Sign-In implementation in Flutter

### 7. Production Checklist
- [ ] Update OAuth consent screen for production
- [ ] Add production domain to authorized redirect URIs
- [ ] Update environment variables for production
- [ ] Verify all redirect URIs are HTTPS in production
- [ ] Test with real Google accounts (not just test users)

## 🔒 Security Notes
- Never commit Client ID/Secret to version control
- Use environment variables for all sensitive data
- In production, use HTTPS for all redirect URIs
- Regularly rotate client secrets
- Limit OAuth scopes to minimum required

## 🐛 Common Issues
1. **"redirect_uri_mismatch"**: Check that redirect URIs match exactly
2. **"invalid_client"**: Verify Client ID and Secret are correct
3. **"access_denied"**: User needs to be added to test users list
4. **CORS errors**: Ensure frontend domain is authorized

## 📝 Example Credentials Structure
```
Web Client:
- Client ID: 123456789-abcdefghijklmnop.apps.googleusercontent.com
- Client Secret: GOCSPX-AbCdEfGhIjKlMnOpQrStUvWxYz

iOS Client:
- Client ID: 123456789-iosspecific.apps.googleusercontent.com
- iOS URL Scheme: com.googleusercontent.apps.123456789-iosspecific

Android Client:
- Client ID: 123456789-androidspecific.apps.googleusercontent.com
```

Save these credentials securely and update your configuration files!
