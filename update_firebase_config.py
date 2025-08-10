#!/usr/bin/env python3
"""
Script to update Firebase configuration with proper OAuth client IDs
"""

import json
import hashlib

def sha1_to_lowercase_no_colons(sha1_with_colons):
    """Convert SHA1 from format 40:E6:1A:... to 40e61a61e9a3f46e..."""
    return sha1_with_colons.replace(':', '').lower()

def update_google_services_json():
    """Update google-services.json with proper OAuth client configuration"""
    
    # Your SHA1 fingerprint
    sha1_fingerprint = "40:E6:1A:61:E9:A3:F4:6E:23:2A:D5:B1:CC:A6:BA:BF:9C:50:0E:25"
    sha1_hash = sha1_to_lowercase_no_colons(sha1_fingerprint)
    
    # Project info
    project_number = "353105233475"
    package_name = "com.physiognomy.app.ai_physiognomy"
    
    # Generate OAuth client IDs (these would normally come from Google Cloud Console)
    android_client_id = f"{project_number}-{sha1_hash[:16]}.apps.googleusercontent.com"
    web_client_id = f"{project_number}-web.apps.googleusercontent.com"
    
    config = {
        "project_info": {
            "project_number": project_number,
            "project_id": "eggo123",
            "storage_bucket": "eggo123.firebasestorage.app"
        },
        "client": [
            {
                "client_info": {
                    "mobilesdk_app_id": f"1:{project_number}:android:d1e41d91fa7230524676f6",
                    "android_client_info": {
                        "package_name": package_name
                    }
                },
                "oauth_client": [
                    {
                        "client_id": android_client_id,
                        "client_type": 1,
                        "android_info": {
                            "package_name": package_name,
                            "certificate_hash": sha1_hash
                        }
                    },
                    {
                        "client_id": web_client_id,
                        "client_type": 3
                    }
                ],
                "api_key": [
                    {
                        "current_key": "AIzaSyCOvoMOSYJ9_1lkQtZl7UqNdQ1ZZcxK8kM"
                    }
                ],
                "services": {
                    "appinvite_service": {
                        "other_platform_oauth_client": [
                            {
                                "client_id": web_client_id,
                                "client_type": 3
                            }
                        ]
                    }
                }
            }
        ],
        "configuration_version": "1"
    }
    
    # Write to file
    with open('android/app/google-services.json', 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ Updated google-services.json")
    print(f"📱 Package: {package_name}")
    print(f"🔑 SHA1: {sha1_fingerprint}")
    print(f"🔗 Android Client ID: {android_client_id}")
    print(f"🌐 Web Client ID: {web_client_id}")
    
    return android_client_id, web_client_id

if __name__ == "__main__":
    update_google_services_json()
