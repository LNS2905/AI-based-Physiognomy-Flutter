# Design Document

## Overview

This design addresses the issue where palm analysis results display in Vietnamese immediately after analysis but show in English when viewed from history. The root cause is that the conversion functions in `FaceScanProvider` generate English default values instead of extracting Vietnamese text from the `palm_interpretation` field in the Cloudinary API response.

The solution involves modifying the data extraction logic to properly parse and preserve Vietnamese content from the `palm_interpretation` structure when converting `PalmAnalysisResponseModel` to `PalmAnalysisDto`.

## Architecture

### Current Flow
1. User performs palm analysis → Cloudinary API returns `PalmAnalysisResponseModel` with Vietnamese `palm_interpretation`
2. Results displayed immediately → Uses Vietnamese data from `palm_interpretation` ✓
3. System saves to backend → Converts to `PalmAnalysisDto` using **English defaults** ✗
4. User views history → Displays saved data which is in English ✗

### Target Flow
1. User performs palm analysis → Cloudinary API returns `PalmAnalysisResponseModel` with Vietnamese `palm_interpretation`
2. Results displayed immediately → Uses Vietnamese data from `palm_interpretation` ✓
3. System saves to backend → Converts to `PalmAnalysisDto` **extracting Vietnamese from palm_interpretation** ✓
4. User views history → Displays saved Vietnamese data ✓

## Components and Interfaces

### Modified Components

#### 1. FaceScanProvider
**Location:** `lib/features/face_scan/presentation/providers/face_scan_provider.dart`

**Modified Methods for Palm Analysis:**
- `_convertToPalmAnalysisDto()` - Main conversion function
- `_generateSummaryTextFromPalmData()` - Extract summary text
- `_generateInterpretationsFromPalmData()` - Extract interpretations
- `_generateLifeAspectsFromPalmData()` - Extract life aspects

**Modified Methods for Facial Analysis:**
- `_convertToFacialAnalysisDto()` - Update fallback text to Vietnamese

**New Helper Methods:**
- `_extractPalmInterpretation()` - Safely extract palm_interpretation from response
- `_extractInterpretationsFromDetailedAnalysis()` - Extract interpretations from detailed_analysis map
- `_extractLifeAspectsFromMap()` - Extract life aspects from life_aspects map

### Data Flow

```
PalmAnalysisResponseModel
  └─ analysis
      └─ palmDetection
          └─ handsData[0]
              └─ palm_interpretation (Map<String, dynamic>)
                  ├─ summary_text (String) → summaryText
                  ├─ detailed_analysis (Map<String, dynamic>)
                  │   ├─ life_line → InterpretationDto
                  │   ├─ head_line → InterpretationDto
                  │   ├─ heart_line → InterpretationDto
                  │   └─ fate_line → InterpretationDto
                  └─ life_aspects (Map<String, dynamic>)
                      ├─ health → LifeAspectDto
                      ├─ career → LifeAspectDto
                      ├─ relationships → LifeAspectDto
                      └─ personality → LifeAspectDto
```

## Data Models

### palm_interpretation Structure (from Cloudinary)

```dart
{
  "summary_text": "Phân tích tổng quan về đường chỉ tay...",
  "detailed_analysis": {
    "life_line": {
      "pattern": "Đường cong rõ ràng",
      "meaning": "Cho thấy sức sống mạnh mẽ..."
    },
    "head_line": {
      "pattern": "Đường thẳng",
      "meaning": "Thể hiện tư duy logic..."
    },
    "heart_line": {
      "pattern": "Đường cong nhẹ",
      "meaning": "Biểu hiện cảm xúc ổn định..."
    },
    "fate_line": {
      "pattern": "Đường rõ ràng",
      "meaning": "Tiềm năng thành công trong sự nghiệp..."
    }
  },
  "life_aspects": {
    "health": ["Sức khỏe tốt...", "Năng lượng dồi dào..."],
    "career": ["Triển vọng nghề nghiệp...", "Khả năng thành công..."],
    "relationships": ["Mối quan hệ ổn định...", "Khả năng kết nối..."],
    "personality": ["Tính cách cân bằng...", "Trí tuệ cảm xúc..."]
  }
}
```

### InterpretationDto Structure (to Backend)

```dart
class InterpretationDto {
  final String lineType;    // 'heart', 'head', 'life', 'fate'
  final String pattern;     // Vietnamese pattern description
  final String meaning;     // Vietnamese meaning description
  final double lengthPx;    // Estimated length
  final double confidence;  // Confidence score
}
```

### LifeAspectDto Structure (to Backend)

```dart
class LifeAspectDto {
  final String aspect;   // 'health', 'career', 'relationships', 'personality'
  final String content;  // Vietnamese content (joined from array)
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Vietnamese Text Preservation
*For any* PalmAnalysisResponseModel with non-null palm_interpretation.summary_text, converting to PalmAnalysisDto should result in summaryText containing the same Vietnamese text
**Validates: Requirements 1.2**

### Property 2: Interpretation Extraction Completeness
*For any* palm_interpretation.detailed_analysis containing palm line data, all available lines (life_line, head_line, heart_line, fate_line) should be converted to InterpretationDto objects with Vietnamese pattern and meaning
**Validates: Requirements 1.3**

### Property 3: Life Aspects Extraction Completeness
*For any* palm_interpretation.life_aspects containing aspect data, all available aspects (health, career, relationships, personality) should be converted to LifeAspectDto objects with Vietnamese content
**Validates: Requirements 1.4**

### Property 4: Null Safety
*For any* PalmAnalysisResponseModel where palm_interpretation or its nested fields are null, the conversion should complete without throwing exceptions and return empty lists for missing data (not fake data)
**Validates: Requirements 2.1, 2.4, 2.5**

### Property 5: Data Consistency
*For any* palm analysis saved to server, retrieving it from history should display the same Vietnamese content that was extracted from the original palm_interpretation
**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

### Property 6: No Fake Data Generation
*For any* PalmAnalysisResponseModel where palm_interpretation is missing or incomplete, the system should return empty results or error messages, never generating fake interpretations or life aspects
**Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**

### Property 7: Vietnamese Fallback Messages
*For any* conversion where API data is missing, all fallback messages and error text should be in Vietnamese, not English
**Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**

## Error Handling

### Extraction Errors
- **Missing palm_interpretation**: Log warning, use minimal error message (no fake data)
- **Null summary_text**: Log warning, use error message indicating missing data
- **Missing detailed_analysis**: Log warning, return empty interpretations list
- **Missing life_aspects**: Log warning, return empty life aspects list
- **Unexpected structure**: Log error with details, continue with partial real data only

### Type Conversion Errors
- **Invalid data types**: Catch and log, use default values
- **Missing required fields**: Use empty string or 0.0 as appropriate
- **Array vs Object mismatch**: Handle both formats gracefully

### Logging Strategy
```dart
AppLogger.info('Extracting palm_interpretation from response');
AppLogger.debug('palm_interpretation structure: $palmInterpretation');
AppLogger.warning('palm_interpretation not found, using fallback');
AppLogger.error('Failed to extract detailed_analysis: $e');
```

## Testing Strategy

### Unit Tests
- Test extraction with complete palm_interpretation data
- Test extraction with partial palm_interpretation data
- Test extraction with null palm_interpretation
- Test extraction with unexpected data types
- Test fallback generation for missing data
- Test Vietnamese text preservation through conversion

### Property-Based Tests
Property-based tests will use the `test` package with custom generators for Dart. Each test will run a minimum of 100 iterations.

**Test Framework:** Dart's built-in `test` package with custom property-based testing utilities

**Property Test 1: Vietnamese Text Preservation**
- Generate random PalmAnalysisResponseModel instances with Vietnamese summary_text
- Convert to PalmAnalysisDto
- Verify summaryText matches original Vietnamese text
- **Feature: palm-analysis-vietnamese-fix, Property 1: Vietnamese Text Preservation**

**Property Test 2: Interpretation Extraction Completeness**
- Generate random palm_interpretation with varying numbers of palm lines
- Convert to PalmAnalysisDto
- Verify all present lines are converted with Vietnamese text preserved
- **Feature: palm-analysis-vietnamese-fix, Property 2: Interpretation Extraction Completeness**

**Property Test 3: Life Aspects Extraction Completeness**
- Generate random palm_interpretation with varying life aspects
- Convert to PalmAnalysisDto
- Verify all present aspects are converted with Vietnamese content preserved
- **Feature: palm-analysis-vietnamese-fix, Property 3: Life Aspects Extraction Completeness**

**Property Test 4: Null Safety**
- Generate random PalmAnalysisResponseModel with various null combinations
- Convert to PalmAnalysisDto
- Verify no exceptions thrown and Vietnamese fallbacks used
- **Feature: palm-analysis-vietnamese-fix, Property 4: Null Safety**

**Property Test 5: Data Consistency**
- Generate random palm analysis data
- Save to mock server
- Retrieve from history
- Verify Vietnamese content matches original
- **Feature: palm-analysis-vietnamese-fix, Property 5: Data Consistency**

**Property Test 6: No Fake Data Generation**
- Generate random PalmAnalysisResponseModel with missing palm_interpretation
- Convert to PalmAnalysisDto
- Verify interpretations and lifeAspects are empty lists (not fake data)
- Verify summaryText contains error message (not fake analysis)
- **Feature: palm-analysis-vietnamese-fix, Property 6: No Fake Data Generation**

**Property Test 7: Vietnamese Fallback Messages**
- Generate random analysis responses with missing data fields
- Convert to DTOs
- Verify all fallback text is in Vietnamese
- Verify no English text appears in fallbacks
- **Feature: palm-analysis-vietnamese-fix, Property 7: Vietnamese Fallback Messages**

## Implementation Notes

### Key Changes

1. **Extract palm_interpretation safely**
   ```dart
   Map<String, dynamic>? _extractPalmInterpretation(PalmAnalysisResponseModel result) {
     try {
       final handsData = result.analysis?.palmDetection?.handsData;
       if (handsData != null && handsData.isNotEmpty) {
         final firstHand = handsData[0];
         if (firstHand is HandDataModel) {
           return firstHand.additionalData?['palm_interpretation'] as Map<String, dynamic>?;
         }
       }
     } catch (e) {
       AppLogger.error('Failed to extract palm_interpretation', e);
     }
     return null;
   }
   ```

2. **Extract summary text with minimal fallback**
   ```dart
   String _generateSummaryTextFromPalmData(PalmAnalysisResponseModel result) {
     final palmInterpretation = _extractPalmInterpretation(result);
     
     if (palmInterpretation != null && palmInterpretation['summary_text'] != null) {
       return palmInterpretation['summary_text'] as String;
     }
     
     // Minimal fallback - indicates missing data, not fake analysis
     AppLogger.warning('palm_interpretation.summary_text not found in API response');
     return 'Không có dữ liệu phân tích chi tiết từ hệ thống. Vui lòng thử lại.';
   }
   ```

3. **Extract interpretations with Vietnamese text - NO FAKE DATA**
   ```dart
   List<InterpretationDto> _generateInterpretationsFromPalmData(PalmAnalysisResponseModel result) {
     final palmInterpretation = _extractPalmInterpretation(result);
     final detailedAnalysis = palmInterpretation?['detailed_analysis'] as Map<String, dynamic>?;
     
     if (detailedAnalysis != null) {
       return _extractInterpretationsFromDetailedAnalysis(detailedAnalysis);
     }
     
     // Return empty list - do not create fake interpretations
     AppLogger.warning('palm_interpretation.detailed_analysis not found in API response');
     return [];
   }
   ```

4. **Update facial analysis conversion with Vietnamese fallback**
   ```dart
   FacialAnalysisDto _convertToFacialAnalysisDto(CloudinaryAnalysisResponseModel analysisResult) {
     final analysis = analysisResult.analysis;
     final face = analysis?.analysisResult?.face;

     // Extract data with fallbacks
     final faceShape = face?.shape?.primary ?? 'Unknown';
     final probabilities = face?.shape?.probabilities ?? <String, double>{};
     final harmonyScore = face?.proportionality?.overallHarmonyScore ?? 0.0;
     final harmonyDetails = face?.proportionality?.harmonyScores ?? <String, double>{};

     // Convert metrics
     final metrics = face?.proportionality?.metrics?.map((metric) {
       return FacialMetricDto(
         orientation: metric.orientation ?? '',
         percentage: metric.percentage ?? 0.0,
         pixels: metric.pixels ?? 0.0,
         label: metric.label ?? '',
       );
     }).toList() ?? <FacialMetricDto>[];

     // Use Vietnamese fallback instead of English
     final resultText = analysis?.result ?? 'Không có dữ liệu phân tích khuôn mặt từ hệ thống. Vui lòng thử lại.';

     return FacialAnalysisDto(
       userId: _authProvider!.userId.toString(),
       resultText: resultText,
       faceShape: faceShape,
       harmonyScore: harmonyScore,
       probabilities: probabilities,
       harmonyDetails: harmonyDetails,
       metrics: metrics,
       annotatedImage: analysisResult.annotatedImageUrl ?? '',
       processedAt: analysisResult.processedAt,
     );
   }
   ```

### Vietnamese Fallback Data

**IMPORTANT:** Fallback data should ONLY be used when data is completely missing from the API response. The system must ALWAYS attempt to extract real data from the API first.

#### Palm Analysis Fallbacks

When palm_interpretation is not available (API error or missing field), use minimal Vietnamese fallback:

**Summary:** "Không có dữ liệu phân tích chi tiết từ hệ thống. Vui lòng thử lại."

**Interpretations:** Empty list - Do not create fake interpretations

**Life Aspects:** Empty list - Do not create fake life aspects

#### Facial Analysis Fallbacks

When facial analysis result text is missing:

**Result Text:** "Không có dữ liệu phân tích khuôn mặt từ hệ thống. Vui lòng thử lại."

**Rationale:** 
- Using fake/mock data misleads users into thinking they received a real analysis
- Empty results clearly indicate a problem that needs attention
- Real data from Cloudinary API should always be available for successful analyses
- If data is missing, it indicates an API integration issue that should be fixed, not hidden with fake data
- Vietnamese error messages help users understand the issue in their native language
