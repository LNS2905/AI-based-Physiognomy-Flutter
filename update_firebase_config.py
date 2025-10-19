#!/usr/bin/env python3
"""
Script to update Firebase configuration with proper OAuth client IDs
"""

import json
import sys

def sha1_to_lowercase_no_colons(sha1_with_colons):
    """Convert SHA1 from format BA:3F:4A:... to ba3f4aa7..."""
    return sha1_with_colons.replace(':', '').lower()

def update_google_services_json(sha1_fingerprint):
    """Update google-services.json with proper OAuth client configuration"""
    
    sha1_hash = sha1_to_lowercase_no_colons(sha1_fingerprint)
    
    # Project info
    project_number = "353105233475"
    package_name = "com.physiognomy.app.ai_physiognomy"
    api_key = "AIzaSyCOvoMOSYJ9_1lkQtZl7UqNdQ1ZZcxK8kM"
    
    # Generate OAuth client IDs
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
                        "current_key": api_key
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
    
    print(f"[SUCCESS] Updated google-services.json")
    print(f"Package: {package_name}")
    print(f"SHA1: {sha1_fingerprint}")
    print(f"SHA1 Hash: {sha1_hash}")
    print(f"Android Client ID: {android_client_id}")
    print(f"Web Client ID: {web_client_id}")
    
    return android_client_id, web_client_id

if __name__ == "__main__":
    # Use SHA-1 from command line or default to the correct one
    if len(sys.argv) > 1:
        sha1 = sys.argv[1]
    else:
        sha1 = "BA:3F:4A:A7:9F:82:37:3F:B7:2E:1D:C9:04:FB:56:89:BD:73:EA:D9"
    
    update_google_services_json(sha1)
