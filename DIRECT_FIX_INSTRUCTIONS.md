# Hướng dẫn SSH trực tiếp để sửa lỗi PostgreSQL hostname

## Vấn đề
Container backend đang tìm hostname `postgres` nhưng container PostgreSQL có tên `glowlab_postgres`.

## Cách sửa nhanh (SSH trực tiếp)

### 1. SSH vào VPS
```bash
ssh root@160.250.180.132
# Password: Do@nhkiet262205
```

### 2. Đọc nội dung entrypoint hiện tại
```bash
docker exec glowlab_backend cat /docker-entrypoint.sh
```

### 3. Sửa file entrypoint
```bash
# Tạo file mới với hostname đúng
cat > /tmp/new-entrypoint.sh << 'EOF'
#!/bin/bash
set -e

echo "Waiting for PostgreSQL..."

# Đổi từ 'postgres' thành 'glowlab_postgres'
until nc -z -v -w30 glowlab_postgres 5432
do
  echo "Waiting for database connection on glowlab_postgres:5432..."
  sleep 1
done

echo "PostgreSQL is ready - starting application"
exec node dist/main.js
EOF

# Cấp quyền thực thi
chmod +x /tmp/new-entrypoint.sh
```

### 4. Copy file mới vào container và restart
```bash
# Copy vào container
docker cp /tmp/new-entrypoint.sh glowlab_backend:/docker-entrypoint.sh

# Cấp quyền thực thi trong container
docker exec glowlab_backend chmod +x /docker-entrypoint.sh

# Restart container
docker restart glowlab_backend
```

### 5. Kiểm tra logs
```bash
# Đợi 15 giây để container khởi động
sleep 15

# Xem logs
docker logs --tail 50 glowlab_backend

# Nếu thấy "PostgreSQL is ready" và "Server listening" => THÀNH CÔNG!
```

### 6. Test API
```bash
# Test endpoint
curl http://localhost:3000/credit-packages

# Nếu trả về JSON với danh sách packages => API hoạt động!
```

## Giải pháp thay thế: Rebuild image

Nếu sửa entrypoint không giữ được sau khi restart, cần rebuild image:

```bash
# 1. Tìm source code của backend
cd /root/ai-physio-be  # hoặc thư mục nào có Dockerfile

# 2. Sửa file entrypoint.sh hoặc docker-entrypoint.sh
# Đổi 'postgres' thành 'glowlab_postgres'
nano docker-entrypoint.sh  # hoặc vim

# 3. Rebuild image
docker build -t glowlab-backend:latest .

# 4. Restart container (sẽ dùng image mới)
docker restart glowlab_backend
```

## Kiểm tra cuối cùng

```bash
# 1. Container có chạy không?
docker ps | grep glowlab_backend

# 2. Logs có lỗi không?
docker logs glowlab_backend 2>&1 | grep -i "error\|fail" | tail -20

# 3. API có respond không?
curl http://localhost:3000/credit-packages

# 4. Stripe config có đúng không?
docker logs glowlab_backend 2>&1 | grep -i stripe
# Không nên thấy "Warning: STRIPE_BASE_URL not configured"
```

## Nếu vẫn gặp vấn đề

Có thể hostname 'postgres' bị hardcode ở nhiều nơi trong code. Kiểm tra:

```bash
# Tìm tất cả các file có chứa 'postgres'
docker exec glowlab_backend find /app -type f -name "*.js" -exec grep -l "postgres" {} \;

# Xem nội dung các file đó
docker exec glowlab_backend grep -r "postgres" /app/dist/ | grep -v "postgresql://"
```

Nếu thấy hardcode trong code, cần sửa source code và rebuild lại image.