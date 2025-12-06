# Requirements Document

## Introduction

Hiện tại, khi người dùng phân tích vân tay, kết quả hiển thị ngay sau phân tích là tiếng Việt (từ API Cloudinary), nhưng khi xem lại từ lịch sử thì lại hiển thị tiếng Anh. Vấn đề này xảy ra vì khi lưu kết quả phân tích vào server, hệ thống không trích xuất đúng dữ liệu tiếng Việt từ response của Cloudinary mà thay vào đó tạo ra các giá trị mặc định bằng tiếng Anh.

Tương tự, phân tích gương mặt cũng cần đảm bảo sử dụng dữ liệu thực từ API và có fallback tiếng Việt phù hợp khi thiếu dữ liệu.

## Glossary

- **PalmAnalysisResponseModel**: Model chứa dữ liệu phản hồi từ API Cloudinary, bao gồm `palm_interpretation` với nội dung tiếng Việt
- **PalmAnalysisDto**: Data Transfer Object được gửi lên server backend để lưu trữ
- **palm_interpretation**: Trường trong response của Cloudinary chứa dữ liệu giải nghĩa tiếng Việt với các key: `summary_text`, `detailed_analysis`, `life_aspects`
- **FaceScanProvider**: Provider quản lý việc phân tích và lưu trữ kết quả vân tay và gương mặt
- **Conversion Functions**: Các hàm chuyển đổi dữ liệu từ Cloudinary response sang DTO format
- **CloudinaryAnalysisResponseModel**: Model chứa dữ liệu phản hồi từ API Cloudinary cho phân tích gương mặt
- **FacialAnalysisDto**: Data Transfer Object được gửi lên server backend để lưu trữ kết quả phân tích gương mặt

## Requirements

### Requirement 1

**User Story:** Là người dùng, tôi muốn xem kết quả phân tích vân tay bằng tiếng Việt cả ở màn hình kết quả ngay sau phân tích và ở màn hình lịch sử, để tôi có thể hiểu rõ nội dung phân tích.

#### Acceptance Criteria

1. WHEN the system converts PalmAnalysisResponseModel to PalmAnalysisDto, THE system SHALL extract Vietnamese text from the palm_interpretation field
2. WHEN palm_interpretation contains summary_text, THE system SHALL use that Vietnamese text instead of generating English default text
3. WHEN palm_interpretation contains detailed_analysis, THE system SHALL extract Vietnamese interpretations for each palm line instead of using English defaults
4. WHEN palm_interpretation contains life_aspects, THE system SHALL extract Vietnamese life aspect content instead of using English defaults
5. WHEN palm_interpretation data is missing or null, THE system SHALL fall back to generating default content in Vietnamese

### Requirement 2

**User Story:** Là developer, tôi muốn hệ thống xử lý dữ liệu palm_interpretation một cách an toàn, để tránh lỗi khi dữ liệu không đầy đủ hoặc có cấu trúc khác.

#### Acceptance Criteria

1. WHEN accessing palm_interpretation fields, THE system SHALL check for null values before extraction
2. WHEN detailed_analysis contains palm line data, THE system SHALL safely extract lineType, pattern, and meaning fields
3. WHEN life_aspects contains aspect data, THE system SHALL safely extract aspect name and content
4. WHEN any extraction fails, THE system SHALL log the error and continue with available data
5. WHEN palm_interpretation structure is unexpected, THE system SHALL handle the exception gracefully without crashing

### Requirement 3

**User Story:** Là người dùng, tôi muốn dữ liệu được lưu trữ đầy đủ và chính xác, để khi xem lại lịch sử tôi nhận được thông tin giống như lúc phân tích ban đầu.

#### Acceptance Criteria

1. WHEN saving palm analysis to server, THE system SHALL preserve all Vietnamese text from palm_interpretation
2. WHEN converting interpretations, THE system SHALL maintain the original lineType, pattern, and meaning values
3. WHEN converting life aspects, THE system SHALL maintain the original aspect name and content
4. WHEN summary text is extracted, THE system SHALL preserve the complete Vietnamese summary
5. WHEN viewing history, THE system SHALL display the same Vietnamese content that was shown in the initial analysis results

### Requirement 4

**User Story:** Là người dùng, tôi muốn chỉ nhận được kết quả phân tích thực từ hệ thống, không phải dữ liệu giả mạo, để tôi có thể tin tưởng vào tính chính xác của phân tích.

#### Acceptance Criteria

1. WHEN palm_interpretation data is available from API, THE system SHALL use only that real data and not generate fake interpretations
2. WHEN palm_interpretation is missing from API response, THE system SHALL return empty results or error message instead of fake data
3. WHEN saving analysis results, THE system SHALL never create mock interpretations or life aspects that were not provided by the API
4. WHEN displaying results to users, THE system SHALL clearly indicate when data is missing rather than showing fabricated content
5. WHEN fallback is needed, THE system SHALL use minimal error messages that inform users of the issue rather than fake analysis content

### Requirement 5

**User Story:** Là người dùng, tôi muốn các thông báo lỗi và fallback text hiển thị bằng tiếng Việt, để tôi có thể hiểu rõ vấn đề xảy ra.

#### Acceptance Criteria

1. WHEN facial analysis resultText is missing from API, THE system SHALL use Vietnamese fallback message instead of English
2. WHEN palm analysis summary_text is missing from API, THE system SHALL use Vietnamese error message
3. WHEN any fallback text is displayed, THE system SHALL use Vietnamese language consistently
4. WHEN error messages are shown to users, THE system SHALL display them in Vietnamese
5. WHEN default values are needed, THE system SHALL use Vietnamese text that clearly indicates missing data
