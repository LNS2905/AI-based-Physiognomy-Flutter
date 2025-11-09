# Chatbot API Implementation Summary

## Overview
Successfully implemented chatbot functionality using the actual API specification from `chatbotapidocs.json`.

## API Endpoints Integrated

### 1. **POST /api/v1/chat/start** - Start New Conversation
- **Request:**
  ```json
  {
    "user_id": integer,
    "chart_id": integer (optional)
  }
  ```
- **Response:** Returns `conversation_id` (integer)
- **Purpose:** Creates a new conversation session for the user

### 2. **POST /api/v1/chat/message** - Send Message
- **Request:**
  ```json
  {
    "conversation_id": integer,
    "message": string
  }
  ```
- **Response:** Returns AI response message
- **Purpose:** Sends user message and receives AI response

### 3. **GET /api/v1/chat/history/{conversation_id}** - Get Conversation History
- **Response:** Returns array of messages with role (user/ai) and content
- **Purpose:** Retrieves message history for a conversation

## Key Changes Made

### 1. **Models Updated**
- ✅ **ConversationModel**: Changed `id` from `String` to `int`
- ✅ **ChatRequestModel**: 
  - Changed `conversationId` from `String?` to `int` (required)
  - Added `@JsonKey(name: 'conversation_id')` for proper serialization
- ✅ **ChatResponseModel**: Changed `conversationId` to `int`
- ✅ **ChatStartModel**: Created new model for starting conversations
  - `ChatStartRequest` with `user_id` and optional `chart_id`
  - `ChatStartResponse` with `conversation_id`

### 2. **Repository Updated (ChatRepository)**
- ✅ **Added `startConversation()`**: Calls `/api/v1/chat/start`
- ✅ **Updated `sendMessage()`**: 
  - Now calls `/api/v1/chat/message`
  - Handles flexible response format from API
- ✅ **Updated `getConversationHistory()`**:
  - Renamed from `getConversation()`
  - Returns `List<ChatMessageModel>` instead of `ConversationModel`
  - Parses message history correctly
- ✅ **Removed methods**: Deleted unused endpoints (getConversations, createConversation, deleteConversation, updateConversationTitle)

### 3. **Provider Updated (ChatProvider)**
- ✅ **Simplified state management**:
  - Changed from managing list of conversations to managing single conversation
  - Now stores `int? _currentConversationId` instead of `ConversationModel?`
  - Stores messages directly as `List<ChatMessageModel>`
- ✅ **Added user management**:
  - Added `UserModel? _currentUser` to get user ID
  - Added `setUser()` and `initialize(UserModel)` methods
- ✅ **Updated flow**:
  - `createNewConversation()`: Calls API to start conversation, gets ID
  - `sendMessage()`: Auto-creates conversation if needed, then sends message
  - `selectConversation()`: Loads history for existing conversation
  - `clearConversation()`: Clears current conversation to start fresh
- ✅ **Removed methods**: Deleted unused operations (deleteConversation, updateConversationTitle, markConversationAsRead)

### 4. **UI Updated (AIConversationPage)**
- ✅ **Changed conversation ID type**: From `String?` to `int?`
- ✅ **Updated initialization**:
  - Gets current user from AuthProvider
  - Passes user to ChatProvider via `setUser()`
  - Auto-clears conversation for new chats
- ✅ **Updated menu actions**:
  - "New Chat" clears conversation instead of creating one
  - "Clear Chat" and "Delete Chat" both clear (API doesn't support delete)
- ✅ **Removed API call**: Removed `authProvider.getCurrentUser()` after sending message

### 5. **Router Updated**
- ✅ **Updated route parsing**: Convert conversation ID from String to int in router

### 6. **Main.dart Updated**
- ✅ **Removed auto-initialization**: ChatProvider no longer calls `initialize()` on creation
- User is set when they navigate to chat page

## Flow Diagram

```
User Opens Chat Page
  ↓
AIConversationPage.initState()
  ↓
Get currentUser from EnhancedAuthProvider
  ↓
chatProvider.setUser(user)
  ↓
If conversationId provided → selectConversation(id)
If no conversationId → clearConversation()
  ↓
User Types Message
  ↓
chatProvider.sendMessage(message)
  ↓
If no conversation → startConversation(userId)
  ↓
POST /api/v1/chat/start → Get conversation_id
  ↓
POST /api/v1/chat/message
  ↓
Display AI Response
```

## Credit System Integration

- Each chat message costs 1 credit
- Credits are checked before sending message
- If insufficient credits, user is redirected to payment page
- Backend automatically deducts credits when message is sent
- No need to manually refresh user data

## Files Modified

1. `/lib/features/ai_conversation/data/models/conversation_model.dart`
2. `/lib/features/ai_conversation/data/models/chat_request_model.dart`
3. `/lib/features/ai_conversation/data/models/chat_start_model.dart` (NEW)
4. `/lib/features/ai_conversation/data/repositories/chat_repository.dart`
5. `/lib/features/ai_conversation/presentation/providers/chat_provider.dart`
6. `/lib/features/ai_conversation/presentation/pages/ai_conversation_page.dart`
7. `/lib/core/navigation/app_router.dart`
8. `/lib/main.dart`

## Testing Checklist

- [ ] Test starting new conversation (creates conversation on first message)
- [ ] Test sending messages and receiving AI responses
- [ ] Test loading conversation history
- [ ] Test credit deduction per message
- [ ] Test insufficient credits dialog
- [ ] Test "New Chat" menu option
- [ ] Test "Clear Chat" dialog
- [ ] Test conversation persistence across navigation
- [ ] Test error handling for API failures
- [ ] Test with existing conversation ID parameter

## Notes

1. **Conversation ID Type**: Changed from String to int to match API
2. **Auto-create on Send**: Conversation is created automatically on first message send
3. **No Delete API**: Backend doesn't provide delete endpoint, so "delete" just clears locally
4. **Flexible Response Parsing**: Repository handles different response formats from API
5. **User Context**: User ID is required to start conversations, obtained from AuthProvider

## Next Steps

1. Test with real backend API
2. Add loading states and error messages
3. Implement message retry on failure
4. Add conversation persistence (save/restore from local storage)
5. Add typing animation for AI responses
6. Consider adding WebSocket support for real-time streaming

## API Base URL

The chatbot API uses the old backend base URL:
```dart
AppConstants.oldBackendBaseUrl = 'http://192.168.100.55:3000/ai'
```

Endpoints are automatically routed there by the HttpService when they start with `/api/v1/chat/`.
