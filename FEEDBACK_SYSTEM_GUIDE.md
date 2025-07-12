# Event Feedback System Setup Guide

## Overview
The event feedback system allows users to provide ratings and comments for events both during and after the event. It includes real-time feedback capabilities, comprehensive analytics for organizers, and moderation features.

## Features Implemented

### 1. **Feedback Model** (`lib/src/models/feedback.dart`)
- **Multiple Rating Types**: Overall, Organization, Venue/Platform, Content, Communication
- **Flexible Feedback**: Both during-event (live) and post-event feedback
- **Anonymous Option**: Users can submit feedback anonymously
- **Moderation**: Flagging system and status management
- **Engagement**: Upvoting system for helpful feedback

### 2. **Feedback Provider** (`lib/src/providers/feedback_provider.dart`)
- **CRUD Operations**: Create, read, update, delete feedback
- **Real-time Streams**: Live feedback updates
- **Analytics**: Comprehensive feedback analytics for organizers
- **Validation**: Ensures only registered users can provide feedback
- **Moderation**: Automatic flagging and hiding of inappropriate content

### 3. **User Interface Components**

#### **Feedback Form** (`lib/src/widgets/feedback_form.dart`)
- Star rating system for different aspects
- Comment section for detailed feedback
- Anonymous submission option
- Live feedback indicator during ongoing events

#### **Feedback Display** (`lib/src/widgets/feedback_display.dart`)
- Feedback summary with average ratings
- Individual feedback cards with user information
- Upvoting and reporting functionality
- Real-time updates

#### **Event Feedback Screen** (`lib/src/screens/feedback/event_feedback_screen.dart`)
- Comprehensive feedback view with tabs
- Overview and detailed review sections
- User's own feedback editing capability

### 4. **Integration Points**

#### **Event Details Screen** 
- Added feedback tab alongside event details
- Quick access to feedback screen via app bar button

#### **Event Management Screen** (for organizers)
- Feedback dashboard card for monitoring event feedback
- Analytics and moderation tools

#### **Event Cards**
- Feedback button for quick access to event feedback

## Database Structure

### Collections Created:
1. **`event_feedback`**: Stores individual feedback entries
2. **`event_feedback_summary`**: Cached summary data for quick access
3. **`feedback_reports`**: Stores user reports for inappropriate content

## Firestore Setup Required

### 1. **Security Rules** (Already updated in `firestore.rules`)
```javascript
// Event feedback rules
match /event_feedback/{feedbackId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
  allow update: if request.auth != null && resource.data.userId == request.auth.uid;
  allow delete: if request.auth != null && resource.data.userId == request.auth.uid;
}
```

### 2. **Indexes Required** (Created in `firestore.indexes.json`)
To fix the "query requires an index" error, deploy these indexes:

```bash
firebase deploy --only firestore
```

### 3. **Manual Index Creation** (Alternative)
If automatic deployment doesn't work, manually create these indexes in Firebase Console:

**Collection: `event_feedback`**
- **Index 1**: `eventId` (Ascending) + `timestamp` (Descending)
- **Index 2**: `eventId` (Ascending) + `status` (Ascending) + `timestamp` (Descending)

**Collection: `registrations`**
- **Index 1**: `eventId` (Ascending) + `userId` (Ascending)
- **Index 2**: `eventId` (Ascending) + `paymentStatus` (Ascending)

## How to Use the Feedback System

### For Event Participants:

1. **During Event**: 
   - Navigate to event details
   - Click "Live Feedback" button (appears red when event is ongoing)
   - Provide real-time ratings and comments

2. **After Event**:
   - Navigate to event details → Feedback tab
   - Click "Add Feedback" to provide comprehensive review
   - Rate different aspects and add detailed comments

### For Event Organizers:

1. **Monitor Feedback**:
   - Go to Event Management → Feedback card
   - View real-time feedback and analytics
   - See rating breakdowns and trends

2. **Moderation**:
   - Flagged content automatically hidden after 3 reports
   - Review reported feedback in the system

### For All Users:

1. **View Feedback**:
   - Event cards now have "Feedback" button
   - Event details screen has dedicated feedback tab
   - Can upvote helpful feedback

## Key Features Explained

### 1. **Live vs Post-Event Feedback**
- **Live Feedback**: Submitted while event is running (marked with red "LIVE" badge)
- **Post-Event**: Comprehensive review after event completion
- System automatically detects event status

### 2. **Rating System**
- **5-star ratings** for multiple aspects:
  - Overall Experience
  - Organization
  - Venue/Platform (adapts based on online/offline)
  - Content Quality
  - Communication

### 3. **Anonymous Feedback**
- Users can choose to submit feedback anonymously
- Anonymous feedback shows as "Anonymous" with generic avatar

### 4. **Feedback Validation**
- Only registered participants can provide feedback
- One feedback per user per event
- Users can edit their own feedback

### 5. **Analytics for Organizers**
- Average ratings by category
- Total feedback count
- Live vs post-event feedback breakdown
- Recent feedback with comments

## Technical Implementation Notes

### Query Optimization
- Modified to avoid complex composite queries that require indexes
- Client-side filtering used where appropriate to reduce index requirements
- Simplified queries with app-level sorting and filtering

### Real-time Updates
- Uses Firestore streams for real-time feedback updates
- Automatic cache invalidation when feedback is submitted
- Live feedback indicators update in real-time

### Error Handling
- Comprehensive error handling for all feedback operations
- User-friendly error messages
- Graceful fallbacks for network issues

## Future Enhancements

1. **Advanced Analytics**: Charts and graphs for feedback trends
2. **Feedback Templates**: Pre-defined feedback categories for different event types
3. **Sentiment Analysis**: Automatic sentiment analysis of feedback comments
4. **Email Notifications**: Notify organizers of new feedback
5. **Feedback Exports**: Export feedback data for external analysis

## Troubleshooting

### Index Errors
If you encounter "query requires an index" errors:
1. Deploy the firestore rules and indexes: `firebase deploy --only firestore`
2. Or manually create indexes in Firebase Console
3. Wait for index building to complete (can take several minutes)

### Permission Errors
Ensure users are properly authenticated and registered for events before allowing feedback submission.

### Real-time Updates Not Working
Check that Firestore listeners are properly set up and disposed of in widget lifecycle methods.

## Testing the System

1. **Create a test event** with a start time in the past (to simulate ongoing event)
2. **Register for the event** with a test user
3. **Submit live feedback** during the "ongoing" event
4. **Submit post-event feedback** after changing event end time to past
5. **Test anonymoius feedback** by toggling the anonymous option
6. **Test upvoting and reporting** by using different test accounts

The feedback system is now fully integrated and ready to use!
