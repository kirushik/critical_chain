# Real-time Editing Feature

This feature enables viewers to see edits made by the editor in real-time using Turbo Streams with ActionCable and PostgreSQL's LISTEN/NOTIFY mechanism.

## Architecture

### Components

1. **ActionCable Enhanced PostgreSQL Adapter** (`actioncable-enhanced-postgresql-adapter` gem)
   - Provides robust PostgreSQL LISTEN/NOTIFY integration for ActionCable
   - Handles connection management and automatic reconnection
   - Used in production environment

2. **RealtimeBroadcastable Concerns**
   - `RealtimeBroadcastable::Estimation` - Broadcasts changes to Estimation model
   - `RealtimeBroadcastable::EstimationItem` - Broadcasts changes to EstimationItem model
   - Both concerns use Turbo::StreamsChannel to render and broadcast HTML partials

3. **Turbo Streams Channel (Turbo::StreamsChannel)**
   - Built-in ActionCable channel used by Turbo Streams
   - Clients subscribe via `turbo_stream_from` in views
   - Subscriptions use stream names like `estimation_{id}` for per-estimation updates

4. **Turbo Streams**
   - Uses `turbo_stream_from` helper in views for viewers
   - Broadcasts rendered HTML partials (not JSON)
   - Cache-friendly approach
   - No custom JavaScript required

### Broadcasting Flow

```
Editor makes change → Model saved → after_commit callback → 
RealtimeBroadcastable concern → Turbo::StreamsChannel.broadcast_* → 
PostgreSQL LISTEN/NOTIFY → Enhanced PostgreSQL Adapter → 
WebSocket clients → Turbo applies DOM updates automatically
```

### Turbo Stream Operations

**Estimation Updates (title changes):**
- Operation: `replace`
- Target: `#estimation_title`
- Partial: `estimations/title`

**EstimationItem Creation:**
- Operation: `append` (item) + multiple `replace` (totals)
- Targets: Table tbody, `#total`, `#sum`, `#buffer`, etc.

**EstimationItem Updates:**
- Operation: multiple `replace`
- Targets: Item row, `#total`, `#sum`, `#buffer`, etc.

**EstimationItem Deletion:**
- Operation: `remove` (item) + multiple `replace` (totals)
- Targets: Item row, `#total`, `#sum`, `#buffer`, etc.

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

- **Broadcaster tests** (`spec/models/concerns/realtime_broadcastable_*_spec.rb`)
  - Verifies concerns are properly included
  - Confirms broadcast methods don't raise errors
  - Tests with proper ActionCable test adapter

All existing tests pass, including existing functionality.

## Usage

### For Viewers

When viewing a shared estimation:
1. `turbo_stream_from` helper establishes WebSocket connection
2. Changes made by the editor are received as Turbo Streams
3. Turbo automatically applies DOM updates
4. No page reload or manual JavaScript needed

### For Editors

When editing an estimation:
1. Changes are saved normally through Turbo Stream responses
2. Updates appear immediately in their browser via Turbo
3. Broadcasts are sent to all viewers
4. No subscription needed (editors see direct Turbo Stream responses)

## Performance Considerations

- **Server-side rendering**: HTML is rendered once on the server and broadcast to all viewers
- **Cacheable partials**: Partials can use fragment caching
- **Selective broadcasting**: Only viewers subscribe; editors use direct Turbo Stream responses
- **Connection pooling**: Enhanced adapter manages PostgreSQL connections efficiently
- **Graceful degradation**: If ActionCable is unavailable, application continues to function normally

## Security

- **Authorization**: Channel subscription requires valid user and estimation access
- **Warden integration**: Uses existing Devise authentication
- **Per-estimation channels**: Users only receive updates for estimations they can access
- **Error handling**: Broadcast failures don't affect database transactions
- **XSS protection**: All content is rendered through Rails ERB with automatic escaping

## Implementation Details

### Viewer Subscription

In `app/views/estimations/show.html.erb`:
```erb
<% unless @estimation.can_edit?(current_user) %>
  <%= turbo_stream_from "estimation_#{@estimation.id}" %>
<% end %>
```

### Broadcasting Example

When an estimation item is updated:
1. `after_commit` callback fires
2. Concern method `broadcast_estimation_item_change` executes
3. Multiple Turbo Streams are broadcast:
   - Replace the updated item row
   - Replace total display
   - Replace sum display  
   - Replace buffer display
   - (If tracking mode) Replace actual_sum and buffer_health

All broadcasts render actual HTML partials server-side, ensuring consistency with the editor's view.
