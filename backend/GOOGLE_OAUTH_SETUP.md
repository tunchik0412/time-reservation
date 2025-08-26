# Google OAuth Setup Guide

This guide explains how to set up Google OAuth authentication for the Time Reservation backend.

## Prerequisites

1. A Google Cloud Console account
2. A project in Google Cloud Console

## Step 1: Create Google OAuth Credentials

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project or create a new one
3. Navigate to "APIs & Services" > "Credentials"
4. Click "Create Credentials" > "OAuth 2.0 Client IDs"
5. Choose "Web application" as the application type
6. Configure the following:
   - **Name**: Time Reservation Backend
   - **Authorized JavaScript origins**: 
     - `http://localhost:3000`
     - `http://192.168.0.199:3000` (your current backend URL)
   - **Authorized redirect URIs**: 
     - `http://localhost:3000/google/callback`
     - `http://192.168.0.199:3000/google/callback`

## Step 2: Configure Environment Variables

Update your `docker-compose.yml` or create a `.env` file with:

```bash
GOOGLE_CLIENT_ID=your_actual_google_client_id_here
GOOGLE_CLIENT_SECRET=your_actual_google_client_secret_here
GOOGLE_CALLBACK_URL=http://192.168.0.199:3000/google/callback
FRONTEND_URL=http://192.168.0.199:3001
```

## Step 3: Database Migration

The User entity has been updated with new fields:
- `googleId` (nullable string)
- `picture` (nullable string)
- `password` (now nullable for Google users)

The database schema will be automatically updated when you restart the backend.

## API Endpoints

### Web OAuth Flow
1. **GET** `/google` - Redirects to Google OAuth consent screen
2. **GET** `/google/callback` - Handles Google OAuth callback

### Mobile/Direct Token Flow
3. **POST** `/google/token` - Accepts Google access token for mobile apps

#### Request Body for `/google/token`:
```json
{
  "googleId": "user_google_id",
  "email": "user@example.com",
  "name": "User Name",
  "picture": "https://...",
  "accessToken": "google_access_token"
}
```

#### Response:
```json
{
  "access_token": "jwt_token",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "User Name",
    "picture": "https://..."
  }
}
```

## Flutter Integration

The backend supports both web OAuth flow and mobile token verification:

1. **Web Flow**: Redirect users to `/google` endpoint
2. **Mobile Flow**: Send Google access token to `/google/token` endpoint

## Security Notes

- Google users are created without passwords
- Existing email users can be linked to Google accounts
- JWT tokens are generated and stored in the tokens table
- All Google API calls are server-side verified

## Testing

1. Start the backend: `docker-compose up -d`
2. Test web flow: Visit `http://192.168.0.199:3000/google`
3. Test mobile flow: Send POST request to `http://192.168.0.199:3000/google/token`
