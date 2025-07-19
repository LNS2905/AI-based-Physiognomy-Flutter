# History Feature

A comprehensive history section for the Flutter app that allows users to view their past chat conversations and analysis results (both face analysis and palm analysis).

## Features

### Core Functionality
- **Unified History View**: Display all types of history items (face analysis, palm analysis, chat conversations) in a single organized list
- **Advanced Filtering**: Filter by type, favorites, date ranges, and custom tags
- **Search Functionality**: Search through history items by title, description, and tags
- **Sorting Options**: Sort by newest, oldest, alphabetical, most used, or favorites
- **Detailed Views**: Tap on any history item to view full details
- **Favorites System**: Mark important items as favorites for quick access
- **Statistics Dashboard**: View usage statistics and recent activity

### History Item Types

#### 1. Face Analysis History
- Displays face analysis results with shape data
- Shows annotated images and analysis metrics
- Links to full analysis results page
- Includes confidence scores and proportionality data

#### 2. Palm Analysis History
- Shows palm analysis results with hand detection data
- Displays annotated and comparison images
- Includes measurement summaries and quality scores
- Links to full palm analysis results page

#### 3. Chat Conversation History
- Displays chat conversations with AI
- Shows message count and conversation duration
- Includes unread message indicators
- Allows continuing conversations from history

## Architecture

### Data Models
- `HistoryItemModel`: Base model for all history items
- `FaceAnalysisHistoryModel`: Specific model for face analysis history
- `PalmAnalysisHistoryModel`: Specific model for palm analysis history
- `ChatHistoryModel`: Specific model for chat conversation history
- `HistoryFilterConfig`: Configuration for filtering and sorting

### Provider
- `HistoryProvider`: Manages history state, filtering, searching, and user interactions
- Handles loading mock data and applying filters
- Manages favorites and deletion operations

### UI Components
- `HistoryItemCard`: Main card component for displaying history items
- `HistoryItemCompactCard`: Compact version for lists
- `HistoryFilterBar`: Filter and sort controls
- `HistoryEmptyState`: Empty state with helpful actions
- `HistoryLoadingState`: Loading indicator
- `HistoryErrorState`: Error handling with retry option

### Pages
- `HistoryPage`: Main history page with tabs and filtering
- `FaceAnalysisHistoryDetailPage`: Detailed view for face analysis items
- `PalmAnalysisHistoryDetailPage`: Detailed view for palm analysis items
- `ChatHistoryDetailPage`: Detailed view for chat conversations

## Mock Data

The feature includes comprehensive mock data generation:

### Face Analysis Mock Data
- 8 sample face analysis results
- Various face shapes (Oval, Round, Square, Heart, Diamond, Oblong)
- Realistic confidence scores and metrics
- Sample images from Unsplash
- Metadata including device type and upload source

### Palm Analysis Mock Data
- 6 sample palm analysis results
- Different hand detection scenarios (1-2 hands)
- Palm line analysis data
- Finger measurements and flexibility scores
- Processing time and quality metrics

### Chat Conversation Mock Data
- 4 sample conversations with realistic topics
- Face analysis explanations
- Palm reading discussions
- General physiognomy questions
- Varied message counts and timestamps

## Navigation Integration

### Routes Added
- `/history` - Main history page
- `/history/face-analysis/:historyId` - Face analysis detail
- `/history/palm-analysis/:historyId` - Palm analysis detail
- `/history/chat/:historyId` - Chat conversation detail

### Home Page Integration
- Added "Lịch sử" (History) card to home page features
- Replaces the generic "Kết quả" (Results) card
- Consistent with existing design patterns

## Design Consistency

### Visual Language
- Follows existing app color scheme (Bagua-inspired)
- Uses consistent typography and spacing
- Maintains Material Design 3 principles
- Responsive design for different screen sizes

### Color Coding
- **Face Analysis**: Primary gold color (`AppColors.primary`)
- **Palm Analysis**: Secondary blue color (`AppColors.secondary`)
- **Chat Conversations**: Success green color (`AppColors.success`)
- **Favorites**: Accent red color (`AppColors.accent`)

### Icons and Indicators
- Face analysis: 👤 emoji + `Icons.face_retouching_natural`
- Palm analysis: ✋ emoji + `Icons.back_hand`
- Chat conversations: 💬 emoji + `Icons.chat_bubble_outline`
- Favorites: `Icons.favorite` / `Icons.favorite_border`

## Usage Examples

### Basic Usage
```dart
// Navigate to history page
context.push('/history');

// Access history provider
final historyProvider = context.read<HistoryProvider>();

// Load history
await historyProvider.initialize();

// Filter by type
historyProvider.setFilter(HistoryFilter.faceAnalysis);

// Search
historyProvider.searchHistory('oval face');

// Toggle favorite
historyProvider.toggleFavorite('face_1');
```

### Custom Filtering
```dart
// Create custom filter configuration
final filterConfig = HistoryFilterConfig(
  filter: HistoryFilter.favorites,
  sort: HistorySort.newest,
  searchQuery: 'analysis',
  tags: ['face', 'oval'],
  dateFrom: DateTime.now().subtract(Duration(days: 7)),
);

// Apply filter
historyProvider.updateFilter(filterConfig);
```

## Future Enhancements

### Planned Features
1. **Export Functionality**: Export history data to PDF or CSV
2. **Cloud Sync**: Synchronize history across devices
3. **Advanced Analytics**: Detailed usage analytics and trends
4. **Backup/Restore**: Backup and restore history data
5. **Sharing**: Share individual history items or summaries
6. **Notifications**: Reminders for follow-up analyses

### Technical Improvements
1. **Pagination**: Implement pagination for large history lists
2. **Caching**: Add intelligent caching for better performance
3. **Offline Support**: Enhanced offline functionality
4. **Real-time Updates**: Live updates when new items are added
5. **Advanced Search**: Full-text search with highlighting

## Dependencies

### Required Packages
- `provider`: State management
- `go_router`: Navigation
- `cached_network_image`: Image caching
- `json_annotation`: JSON serialization
- `equatable`: Value equality

### Internal Dependencies
- Face scan models and providers
- Palm scan models and providers
- AI conversation models and providers
- Core theme and navigation systems

## Testing

### Unit Tests
- Model serialization/deserialization
- Provider state management
- Filter and search logic
- Mock data generation

### Widget Tests
- History item cards rendering
- Filter bar interactions
- Empty state displays
- Navigation flows

### Integration Tests
- End-to-end history workflows
- Navigation between detail pages
- Provider integration with UI
- Mock data loading and display

## Accessibility

### Features Implemented
- Semantic labels for screen readers
- High contrast color support
- Keyboard navigation support
- Touch target size compliance
- Text scaling support

### WCAG Compliance
- AA level color contrast ratios
- Meaningful focus indicators
- Alternative text for images
- Logical tab order
- Error message clarity
