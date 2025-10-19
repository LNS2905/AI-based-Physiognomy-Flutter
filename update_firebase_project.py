#!/usr/bin/env python3
"""
Script to update Firebase project configuration in Flutter app
Run this after creating a new Firebase project
"""

import json
import os
import re

def update_firebase_config():
    print("=== Update Firebase Project Configuration ===\n")
    
    # Get new Firebase project info from user
    print("Please enter your new Firebase project information:")
    print("(You can find these in Firebase Console -> Project Settings)\n")
    
    web_client_id = input("Web Client ID (from OAuth 2.0 Client IDs): ").strip()
    
    if not web_client_id:
        print("ERROR: Web Client ID is required!")
        return
    
    # Validate Web Client ID format
    if not web_client_id.endswith('.apps.googleusercontent.com'):
        print("WARNING: Web Client ID should end with '.apps.googleusercontent.com'")
        confirm = input("Continue anyway? (y/n): ").strip().lower()
        if confirm != 'y':
            return
    
    print("\n=== Updating Files ===\n")
    
    # 1. Update GoogleSignInService
    google_sign_in_file = 'lib/core/services/google_sign_in_service.dart'
    if os.path.exists(google_sign_in_file):
        with open(google_sign_in_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace serverClientId
        new_content = re.sub(
            r"serverClientId:\s*'[^']*'",
            f"serverClientId: '{web_client_id}'",
            content
        )
        
        with open(google_sign_in_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"[SUCCESS] Updated {google_sign_in_file}")
    else:
        print(f"[WARNING] File not found: {google_sign_in_file}")
    
    print("\n=== Configuration Summary ===")
    print(f"Web Client ID: {web_client_id}")
    
    print("\n=== Next Steps ===")
    print("1. Make sure you copied google-services.json to android/app/")
    print("2. Make sure you copied GoogleService-Info.plist to ios/Runner/ (if iOS)")
    print("3. Run: flutter clean")
    print("4. Run: flutter pub get")
    print("5. Run: flutter run")
    print("\n[DONE] Configuration updated successfully!")

if __name__ == "__main__":
    update_firebase_config()
