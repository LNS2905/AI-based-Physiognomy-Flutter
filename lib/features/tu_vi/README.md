# Tu Vi (Vietnamese Astrology) Feature

## Overview
Complete production-ready Tu Vi feature for the AI-based Physiognomy Flutter app, providing beautiful Vietnamese astrology chart generation and analysis.

## Feature Structure

```
lib/features/tu_vi/
├── data/
│   ├── models/
│   │   ├── tu_vi_chart_request.dart       # Request model with JSON serialization
│   │   ├── tu_vi_chart_response.dart      # Main response model
│   │   ├── tu_vi_house.dart               # House (Cung) model with 12 palaces
│   │   ├── tu_vi_star.dart                # Star (Sao) model with elements
│   │   └── tu_vi_extra.dart               # Additional chart information
│   └── repositories/
│       └── tu_vi_repository.dart          # API repository with HTTP calls
├── presentation/
│   ├── pages/
│   │   ├── tu_vi_input_page.dart          # Beautiful input form
│   │   └── tu_vi_result_page.dart         # Rich chart display
│   ├── providers/
│   │   └── tu_vi_provider.dart            # State management
│   └── widgets/
│       └── element_widgets.dart           # Reusable UI components
```

## Features Implemented

### 1. Data Layer
- **Models with JSON Serialization**: All models use `json_serializable` for automatic serialization
- **Type-safe API**: Proper typing for all fields with Vietnamese terminology
- **Comprehensive Mapping**:
  - 14 main stars (Chính tinh)
  - 12 houses (12 Cung)
  - Elements (Ngũ hành): Kim, Mộc, Thủy, Hỏa, Thổ
  - Star strengths: Vượng, Miếu, Hòa, Đắc địa
  - Yin/Yang (Âm/Dương) properties

### 2. Repository Layer
- **API Endpoints**:
  - `POST /charts` - Create new Tu Vi chart
  - `GET /charts/{id}` - Get existing chart
  - `GET /charts?limit=N` - List recent charts
- **Error Handling**: Proper error mapping to Failure classes
- **Network Timeouts**: 10-second timeout for requests
- **UTF-8 Support**: Full Vietnamese character support

### 3. State Management
- **BaseProvider Extension**: Extends app's BaseProvider for consistency
- **Loading States**: Proper loading indicators
- **Error States**: User-friendly error messages
- **Chart Caching**: Current chart and history management
- **Validation**: Request validation before submission

### 4. UI - Input Page (`tu_vi_input_page.dart`)
Beautiful, user-friendly form with:
- **Name Input**: Optional name field
- **Date Picker**: Material date picker with Vietnamese locale
- **Hour Selection**: Dropdown with 12 hour branches (Tý to Hợi) and time ranges
- **Gender Selection**: Radio buttons for Nam/Nữ
- **Calendar Toggle**: Switch between Solar/Lunar calendar
- **Loading States**: Circular progress indicator during submission
- **Error Handling**: SnackBar notifications for errors
- **Material Design 3**: Modern, rounded corners, elevated cards

### 5. UI - Result Page (`tu_vi_result_page.dart`)
Comprehensive chart display with:

#### Header Section
- Name and gender display
- Solar and Lunar dates side-by-side
- Birth hour in Can Chi format
- Gradient background with brand colors

#### Main Info Card
- **Mệnh chủ** (Main destiny star) with star icon
- **Thân chủ** (Body star) with half-star icon
- **Bản mệnh** (Life element) with element display
- **Cục** (Palace type) with element
- **Mệnh vs Cục** relationship (highlighted)
- **Âm dương mệnh** status (Yin/Yang harmony)

#### 12 Houses Display
- **Card-based Layout**: Each house in an ExpansionTile
- **Visual Hierarchy**:
  - Cung Mệnh (Main house) - Purple border, bold
  - Cung Thân (Body house) - Blue border, bold
  - Other houses - Standard card
- **House Information**:
  - House number with element-colored badge
  - House name and description
  - Branch (Chi) and Element
  - Yin/Yang indicator
  - Major period (Đại hạn) if applicable
- **Star Display**:
  - Main stars (14 Chính tinh) prominently displayed
  - Supporting stars in separate section
  - Color-coded by element
  - Strength badges (V/M/H/Đ)
  - Star icons for main stars
- **Special Warnings**:
  - Tuần Triệt (weak house) - Orange warning
  - Triệt Lộ (interrupted house) - Red warning

#### 14 Main Stars Section
- All 14 main stars displayed with chips
- Color-coded by element
- Star icon for visual distinction

#### Additional Information
- Can Chi for year, month, day, hour
- Yin/Yang of birth year
- Timezone
- Chart creation date

### 6. UI Components (`element_widgets.dart`)
Reusable widgets:
- **ElementChip**: Color-coded element badges
- **StarChipWidget**: Star display with name, element, and strength
- **StrengthBadge**: Visual strength indicators

## Color Coding

### Elements (Ngũ hành)
- **Kim** (Metal): Gold (#FFD700)
- **Mộc** (Wood): Green (#4CAF50)
- **Thủy** (Water): Blue (#2196F3)
- **Hỏa** (Fire): Red (#F44336)
- **Thổ** (Earth): Brown (#795548)

### Star Categories
- Main stars (category=1): Bold, with star icon, 2px border
- Supporting stars: Normal weight, 1px border

### Strength Levels
- **Vượng**: Purple
- **Miếu**: Blue
- **Hòa**: Green
- **Đắc địa**: Orange

## Navigation

### Routes Added
- `/tu-vi-input` - Production input page
- `/tu-vi-result/:chartId` - Result page with chart ID
- `/tu-vi-test` - Debug/testing page (existing)

### Router Methods
```dart
AppRouter.goToTuViInput();
AppRouter.goToTuViResult(chartId);
AppRouter.pushTuViInput();
AppRouter.pushTuViResult(chartId);
```

### Welcome Page Integration
- Production button: Auto Awesome icon (top-right)
- Test button: Stars icon (for debugging)

## API Configuration

### Backend URL
- Android Emulator: `http://10.0.2.2:8000`
- iOS Simulator: `http://localhost:8000`
- Physical device: Use computer's IP address

### Request Format
```json
{
  "day": 15,
  "month": 8,
  "year": 1990,
  "hour_branch": 1,
  "gender": 1,
  "name": "Nguyễn Văn A",
  "solar_calendar": true,
  "timezone": 7
}
```

### Response Structure
- `id`: Chart ID (null for new charts)
- `request`: Original request data
- `houses`: Array of 12 houses with stars
- `extra`: Additional information (Can Chi, elements, etc.)

## Usage

### Creating a Chart
```dart
final provider = Provider.of<TuViProvider>(context, listen: false);

final request = TuViChartRequest(
  day: 15,
  month: 8,
  year: 1990,
  hourBranch: 1,
  gender: 1,
  name: "Nguyễn Văn A",
  solarCalendar: true,
  timezone: 7,
);

final chart = await provider.createChart(request);
if (chart != null) {
  // Navigate to result page
  context.push('/tu-vi-result/${chart.id}');
}
```

### Displaying a Chart
```dart
final provider = Provider.of<TuViProvider>(context);
await provider.getChart(chartId);

// Access chart data
final chart = provider.currentChart;
if (chart != null) {
  final mainHouse = chart.mainHouse;
  final bodyHouse = chart.bodyHouse;
  final menhChu = chart.extra.menhChu;
}
```

## Testing

### Test the Feature
1. Run the app on Android Emulator
2. Ensure backend server is running at `http://localhost:8000`
3. From welcome page, tap the Auto Awesome icon (top-right)
4. Fill in the form:
   - Enter name (optional)
   - Select birth date
   - Choose hour branch
   - Select gender
   - Choose calendar type
5. Tap "Lập Lá Số" button
6. View the beautiful chart result

### Test Data
- Name: Nguyễn Văn A
- Date: 15/8/1990
- Hour: Tý (23h-01h)
- Gender: Nam
- Calendar: Dương lịch

## Dependencies
All dependencies already in `pubspec.yaml`:
- `provider: ^6.1.5` - State management
- `http: ^1.4.0` - HTTP requests
- `json_annotation: ^4.9.0` - JSON serialization
- `equatable: ^2.0.7` - Value equality
- `go_router: ^15.2.4` - Navigation
- `intl: ^0.20.2` - Date formatting

## Code Quality
- Type-safe models with JSON serialization
- Proper error handling with try-catch
- Loading states for better UX
- Responsive design with Material Design 3
- Follows Flutter best practices
- Uses existing app architecture (BaseProvider, ApiResult, etc.)
- Clean code with comments
- Vietnamese UI throughout

## Future Enhancements
- Share chart functionality
- Save/favorite charts
- Chart comparison
- Detailed star explanations
- Period analysis (Đại hạn/Tiểu hạn)
- Print/export chart
- Offline chart storage
- Search saved charts

## Screenshots-Worthy UI Elements
1. **Gradient Header Card**: Name, dates, and birth hour with beautiful gradient
2. **Main Info Section**: Icons and color-coded elements for main destiny info
3. **12 Houses Grid**: Expandable cards with proper hierarchy and colors
4. **Star Chips**: Beautiful color-coded chips with strength badges
5. **Special Warnings**: Orange/Red warnings for house issues
6. **Element Color Coding**: Consistent color scheme throughout

## Files Modified
- `lib/main.dart` - Added TuViProvider
- `lib/core/navigation/app_router.dart` - Added Tu Vi routes and helper methods
- `lib/features/welcome/presentation/pages/welcome_page.dart` - Added production button

## Files Created
- 5 model files (+ 5 generated .g.dart files)
- 1 repository file
- 1 provider file
- 2 page files
- 1 widget file
Total: **15 new files**

---

**Built with Flutter and Material Design 3**
**Production-ready Tu Vi feature complete!**
