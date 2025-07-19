#!/usr/bin/env python3
"""
Script để upload ảnh vân tay lên Cloudinary và tạo body request cho palm analysis API
Sử dụng: python upload_palm_image.py
"""

import os
import json
import hashlib
import hmac
import time
import requests
from datetime import datetime, timedelta

# Thông tin Cloudinary từ constants
CLOUDINARY_CLOUD_NAME = 'dd0wymyqj'
CLOUDINARY_API_KEY = '389718786139835'
CLOUDINARY_API_SECRET = 'aS_7wWncQjOLpKRKnHEd0_dr07M'
UPLOAD_FOLDER = 'physiognomy_analysis'

# API endpoint
PALM_ANALYSIS_API_URL = 'https://inspired-bear-emerging.ngrok-free.app/analyze-palm-cloudinary/'

def generate_signature(params_to_sign, api_secret):
    """Tạo signature cho Cloudinary API"""
    # Sắp xếp parameters theo alphabet và tạo query string
    sorted_params = sorted(params_to_sign.items())
    query_string = '&'.join([f'{k}={v}' for k, v in sorted_params])
    
    # Thêm API secret vào cuối
    string_to_sign = f'{query_string}{api_secret}'
    
    # Tạo SHA1 hash
    signature = hashlib.sha1(string_to_sign.encode('utf-8')).hexdigest()
    return signature

def upload_to_cloudinary(image_path):
    """Upload ảnh lên Cloudinary"""
    try:
        print(f'📤 Đang upload ảnh: {image_path}')
        
        # Kiểm tra file tồn tại
        if not os.path.exists(image_path):
            print(f'❌ Không tìm thấy file: {image_path}')
            return None
        
        # Tạo timestamp và public_id
        timestamp = int(time.time())
        public_id = f'palm_analysis_{timestamp}'
        
        # Parameters để sign
        params_to_sign = {
            'public_id': public_id,
            'timestamp': str(timestamp),
            'folder': UPLOAD_FOLDER,
            'type': 'private'  # Upload as private để có thể tạo signed URL
        }
        
        # Tạo signature
        signature = generate_signature(params_to_sign, CLOUDINARY_API_SECRET)
        
        # Chuẩn bị upload request
        upload_url = f'https://api.cloudinary.com/v1_1/{CLOUDINARY_CLOUD_NAME}/image/upload'
        
        # Data cho request
        data = {
            'api_key': CLOUDINARY_API_KEY,
            'timestamp': timestamp,
            'signature': signature,
            'public_id': public_id,
            'folder': UPLOAD_FOLDER,
            'type': 'private'
        }
        
        # File để upload
        with open(image_path, 'rb') as f:
            files = {'file': f}
            
            # Gửi request
            response = requests.post(upload_url, data=data, files=files)
        
        if response.status_code == 200:
            result = response.json()
            print('✅ Upload thành công!')
            print(f'🔗 Public ID: {result["public_id"]}')
            print(f'🔗 Secure URL: {result["secure_url"]}')
            return result
        else:
            print(f'❌ Upload thất bại: {response.status_code}')
            print(f'Response: {response.text}')
            return None
            
    except Exception as e:
        print(f'❌ Lỗi upload: {e}')
        return None

def generate_signed_url(public_id, expires_in_hours=24):
    """Tạo signed URL cho private resource"""
    try:
        # Đối với private resources, chúng ta sẽ sử dụng secure_url từ upload response
        # hoặc tạo URL đơn giản hơn

        # Sử dụng URL đơn giản cho private resource
        signed_url = f'https://res.cloudinary.com/{CLOUDINARY_CLOUD_NAME}/image/private/{public_id}.jpg'

        return signed_url

    except Exception as e:
        print(f'❌ Lỗi tạo signed URL: {e}')
        return None

def create_palm_analysis_request(signed_url, folder_path):
    """Tạo body request cho palm analysis API"""
    return {
        'signed_url': signed_url,
        'user_id': f'test_user_{int(time.time())}',
        'timestamp': datetime.now().isoformat(),
        'original_folder_path': folder_path
    }

def test_palm_analysis_api(request_body):
    """Test gọi API palm analysis"""
    try:
        print('\n🧪 Test gọi API palm analysis...')
        
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true'
        }
        
        response = requests.post(
            PALM_ANALYSIS_API_URL,
            headers=headers,
            json=request_body,
            timeout=120  # 2 minutes timeout
        )
        
        print(f'📊 Response Status: {response.status_code}')
        print(f'📊 Response Headers: {dict(response.headers)}')
        
        if response.status_code == 200:
            print('✅ API call thành công!')
            response_data = response.json()
            print('📄 Response data:')
            print(json.dumps(response_data, indent=2, ensure_ascii=False))
        else:
            print(f'❌ API call thất bại: {response.status_code}')
            print(f'Response body: {response.text}')
            
    except requests.exceptions.Timeout:
        print('❌ API call timeout (>2 minutes)')
    except Exception as e:
        print(f'❌ API call error: {e}')

def main():
    """Main function"""
    try:
        print('🚀 Bắt đầu xử lý ảnh vân tay...')
        
        # Đường dẫn đến file ảnh
        image_path = 'vantay.jpg'
        
        # Kiểm tra file
        if not os.path.exists(image_path):
            print(f'❌ Không tìm thấy file: {image_path}')
            return
        
        file_size = os.path.getsize(image_path)
        print(f'✅ Tìm thấy file ảnh: {image_path}')
        print(f'📏 Kích thước file: {file_size} bytes')
        
        # Upload lên Cloudinary
        upload_result = upload_to_cloudinary(image_path)
        if not upload_result:
            return
        
        # Sử dụng secure_url từ upload response
        signed_url = upload_result['secure_url']

        print(f'🔐 Signed URL: {signed_url}')
        
        # Tạo body request
        request_body = create_palm_analysis_request(signed_url, UPLOAD_FOLDER)
        
        print('\n📋 Body request cho API palm analysis:')
        print('=' * 50)
        print(json.dumps(request_body, indent=2, ensure_ascii=False))
        print('=' * 50)
        
        # Test API call
        test_palm_analysis_api(request_body)
        
        print('\n✅ Hoàn thành!')
        
    except Exception as e:
        print(f'❌ Lỗi: {e}')
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()
