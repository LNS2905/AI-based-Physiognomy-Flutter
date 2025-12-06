# Tóm tắt Module Tử Vi (Tu Vi)

## Tổng quan
Module Tử Vi là tính năng lập và xem lá số tử vi dựa trên thông tin ngày sinh, giờ sinh, giới tính của người dùng.

## Cấu trúc Module

### 1. Data Layer
**Models** (`lib/features/tu_vi/data/models/`)
- `tu_vi_chart_request.dart`: Model request để tạo lá số
  - `day`, `month`, `year`: Ngày sinh
  - `hourBranch`: Chi giờ (1-12, tương ứng Tý đến Hợi)
  - `gender`: Giới tính (1 = Nam, -1 = Nữ)
  - `solarCalendar`: Dương lịch (true) hay Âm lịch (false)
  - `timezone`: Múi giờ (default: 7 cho VN)

- `tu_vi_chart_response.dart`: Model response chứa thông tin lá số
- `tu_vi_house.dart`: Thông tin 12 cung (Mệnh, Thân, Phúc Đức, v.v.)
- `tu_vi_star.dart`: Thông tin các sao (Chính tinh, Phụ tinh)
- `tu_vi_extra.dart`: Thông tin bổ sung (Mệnh chủ, Thân chủ, Cục, v.v.)

**Repository** (`lib/features/tu_vi/data/repositories/`)
- `tu_vi_repository.dart`: Xử lý API calls để tạo và lấy lá số tử vi

### 2. Presentation Layer

**Pages** (`lib/features/tu_vi/presentation/pages/`)
- `tu_vi_input_page.dart`: Màn hình nhập thông tin để lập lá số
  - Form nhập: Họ tên, Ngày sinh, Giờ sinh, Giới tính
  - Toggle Dương lịch/Âm lịch
  - Validate input trước khi submit
  
- `tu_vi_result_page.dart`: Màn hình hiển thị kết quả lá số
  - Header: Thông tin cơ bản (Tên, ngày sinh, giờ sinh)
  - Thông tin chính: Mệnh chủ, Thân chủ, Bản mệnh, Cục
  - 12 Cung: Chi tiết các cung với các sao
  - 14 Chính tinh
  - Thông tin bổ sung: Can Chi năm/tháng/ngày/giờ

**Providers** (`lib/features/tu_vi/presentation/providers/`)
- `tu_vi_provider.dart`: State management cho Tu Vi feature
  - `createChart()`: Tạo lá số mới
  - `getChart()`: Lấy lá số theo ID
  - Validation logic

**Widgets** (`lib/features/tu_vi/presentation/widgets/`)
- `element_widgets.dart`: Widgets hiển thị ngũ hành, sao

## Navigation Routes

### Đã được cấu hình trong `app_router.dart`:
- `/tu-vi-input`: Màn hình nhập thông tin (TuViInputPage)
- `/tu-vi-result/:chartId`: Màn hình kết quả (TuViResultPage)

### Helper methods có sẵn:
```dart
AppRouter.goToTuViInput();
AppRouter.pushTuViInput();
AppRouter.goToTuViResult(chartId);
AppRouter.pushTuViResult(chartId);
```

## Đã thực hiện

### ✅ Đã thêm button Tử Vi vào Home Page
**Vị trí**: `lib/features/home/presentation/pages/home_page.dart`

**Thay đổi**:
1. Thêm feature card "Lá Số Tử Vi" vào danh sách feature cards
2. Cập nhật responsive layout:
   - **Mobile**: Grid 2x3 (2-2-1 pattern)
     - Row 1: Quét khuôn mặt, Quét đường chỉ tay
     - Row 2: Lá Số Tử Vi, AI Chatbot  
     - Row 3: Lịch sử (centered)
   - **Tablet**: Grid 3 cột (3-2 pattern cho 5 cards)
   - **Large Tablet**: Grid 5 cột (single row)

**Icon**: `Icons.auto_awesome` (biểu tượng sao lấp lánh)
**Route**: `/tu-vi-input`

## Luồng sử dụng

1. User nhấn button "Lá Số Tử Vi" trên Home Page
2. Navigate đến `/tu-vi-input` (TuViInputPage)
3. User nhập thông tin:
   - Họ tên (optional)
   - Ngày sinh (date picker)
   - Giờ sinh (dropdown 12 chi)
   - Giới tính (radio: Nam/Nữ)
   - Loại lịch (toggle: Dương/Âm)
4. Nhấn "Lập Lá Số"
5. API call tạo chart, lưu tự động
6. Navigate đến `/tu-vi-result/:chartId` (TuViResultPage)
7. Hiển thị kết quả lá số đầy đủ

## API Integration
Module này kết nối với backend API để:
- POST `/tu-vi/charts`: Tạo lá số mới
- GET `/tu-vi/charts/:id`: Lấy lá số theo ID

## Design System
- **Primary Color**: `#FFC107` (vàng)
- **Card Style**: Rounded 12px, border with elevation
- **Gradient**: Yellow gradient cho banner
- **Icons**: Material Icons
- **Typography**: Bold titles, regular body text

## Notes
- Lá số được lưu tự động sau khi tạo
- Hỗ trợ cả Dương lịch và Âm lịch
- Hiển thị đầy đủ 12 cung và các sao
- Có indicator đặc biệt cho Cung Mệnh và Cung Thân
- Responsive design cho mobile, tablet, desktop
