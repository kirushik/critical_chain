# Real-time Editing Feature

This feature enables viewers to see edits made by the editor in real-time using ActionCable with PostgreSQL's LISTEN/NOTIFY mechanism.

## Architecture

### Components

1. **ActionCable Enhanced PostgreSQL Adapter** (`actioncable-enhanced-postgresql-adapter` gem)
   - Provides robust PostgreSQL LISTEN/NOTIFY integration for ActionCable
   - Handles connection management and automatic reconnection
   - Used in production environment

2. **Broadcastable Concerns**
   - `Broadcastable::Estimation` - Broadcasts changes to Estimation model
   - `Broadcastable::EstimationItem` - Broadcasts changes to EstimationItem model
   - Both concerns send lightweight notifications (< 200 bytes) containing only IDs and metadata

3. **EstimationUpdatesChannel**
   - ActionCable channel that handles WebSocket connections
   - Authorizes users based on estimation ownership or sharing
   - Subscribes users to `estimation_{id}` channels

4. **Stimulus Controller** (`estimation-realtime`)
   - Client-side controller that manages WebSocket subscriptions
   - Only reloads page for viewers (not editors making changes)
   - Editors see their changes immediately through Turbo Stream responses

### Payload Size Management

The implementation strictly adheres to PostgreSQL's 8KB NOTIFY payload limit by:

- **Sending only metadata**: Broadcasts contain only `type`, `estimation_id`, `estimation_item_id`, `action`, and `timestamp`
- **No data duplication**: Actual data (titles, values, etc.) is fetched separately via page reload
- **Typical payload size**: < 200 bytes per notification
- **Tested limits**: Comprehensive tests verify payload sizes stay under limits even with:
  - Maximum-length titles (255 characters)
  - Estimations with 50+ items
  - Large item quantities and values

### Broadcasting Flow

```
Editor makes change → Model saved → after_commit callback → 
Broadcastable concern → ActionCable.server.broadcast → 
PostgreSQL LISTEN/NOTIFY → Enhanced PostgreSQL Adapter → 
WebSocket clients → Stimulus controller → Turbo.visit (viewers only)
```

## Configuration

### Production (config/cable.yml)
```yaml
production:
  adapter: enhanced_postgresql
  url: <%= ENV.fetch("DATABASE_URL") %>
```

### Test (config/cable.yml)
```yaml
test:
  adapter: test
```

### Development (config/cable.yml)
```yaml
development:
  adapter: async
```

## Testing

The feature includes comprehensive test coverage:

- **Broadcaster tests** (`spec/models/concerns/broadcastable_*_spec.rb`)
  - Verifies broadcasts on create/update/destroy
  - Validates payload size limits
  - Confirms payload structure

- **Channel tests** (`spec/channels/estimation_updates_channel_spec.rb`)
  - Tests authorization (owner, shared user, unauthorized)
  - Verifies stream subscriptions
  - Tests cleanup on unsubscribe

All tests use ActionCable's test adapter (no stubbing required).

## Usage

### For Viewers

When viewing a shared estimation:
1. WebSocket connection is automatically established
2. Changes made by the editor are received in real-time
3. Page automatically reloads to show updated data
4. No action required from the viewer

### For Editors

When editing an estimation:
1. Changes are saved normally through Turbo Stream
2. Updates appear immediately in their browser
3. Broadcasts are sent to all viewers
4. No additional setup required

## Performance Considerations

- **Lightweight notifications**: Only IDs are broadcast, not full data
- **Selective reloading**: Only viewers reload; editors see instant updates
- **Connection pooling**: Enhanced adapter manages PostgreSQL connections efficiently
- **Graceful degradation**: If ActionCable is unavailable, application continues to function normally

## Security

- **Authorization**: Channel subscription requires valid user and estimation access
- **Warden integration**: Uses existing Devise authentication
- **Per-estimation channels**: Users only receive updates for estimations they can access
- **Error handling**: Broadcast failures don't affect database transactions
