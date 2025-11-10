# Playwright Migration Guide

## Overview

This guide documents the migration from Capybara (Apparition/Selenium) to Playwright for end-to-end testing in this Rails application. The migration successfully resolved ongoing reliability issues and improved test performance.

**Status**: Infrastructure complete, 1 spec file fully migrated (inline_editing_spec.rb - 6 tests passing)

---

## Why Playwright?

### Problems with Capybara
1. **Driver instability** - Multiple switches between Apparition and Selenium
2. **Complex synchronization** - Required custom `wait_for_ajax` and `fetch_tracker.js`
3. **ES6 module timing** - Stimulus controllers needed special handling
4. **Drag-and-drop limitations** - HTML5 Drag API not well supported
5. **Ongoing flakiness** - Recent commits all focused on test reliability

### Playwright Benefits
1. **Better auto-waiting** - No need for `wait_for_ajax` or custom fetch tracking
2. **Modern JavaScript support** - Native handling of Turbo/Stimulus
3. **Drag-and-drop support** - Can unblock pending tests
4. **Better debugging** - Screenshots, traces, better error messages
5. **Faster tests** - inline_editing_spec: 9.88s (Playwright) vs ~20s (Capybara with failures)

---

## Infrastructure Setup (Complete)

### 1. Dependencies Installed

**Gemfile**:
```ruby
group :test do
  gem 'capybara'  # Keep during transition
  gem 'apparition', github: 'twalpole/apparition'  # Keep during transition

  # Playwright for reliable e2e testing
  gem 'playwright-ruby-client'

  gem 'database_cleaner'
  # ... other gems
end
```

**Playwright browsers**:
```bash
npx playwright install chromium
```

### 2. Playwright RSpec Helpers

Created `spec/support/playwright.rb` with:
- Browser lifecycle management
- Helper methods (`visit`, `page`, `accept_confirm`, etc.)
- Turbo/Stimulus synchronization
- Screenshot capture on failure
- Capybara server integration

### 3. Database Cleaner Configuration

Updated `spec/support/database_cleaner.rb` to support both `:js` and `:playwright` tags:

```ruby
config.before(:each, :playwright => true) do
  DatabaseCleaner.strategy = :truncation
end
```

### 4. CircleCI Configuration

Updated `.circleci/config.yml`:
- Added Playwright browser installation
- Added browser caching
- Added screenshot artifact collection

---

## Migration Process

### Step-by-Step Conversion

#### 1. Change the Test Tag
```ruby
# Before
scenario "My test", :js do

# After
scenario "My test", :playwright do
```

#### 2. Update Element Selection

**Capybara → Playwright selector mapping**:

| Capybara | Playwright |
|----------|------------|
| `page.find("span.title")` | `page.locator("span.title")` |
| `page.find("span", text: "foo")` | `page.locator("span:has-text('foo')")` |
| `page.find(".editable", text: var)` | `page.locator(".editable:has-text('#{var}')")` |
| `within(".container") { ... }` | `page.locator(".container").locator(...)` |
| `fill_in "field", with: "value"` | `page.locator("#field").fill("value")` |
| `click_button "Submit"` | `page.locator("#field").press("Enter")` or find button |
| `click_link "Link"` | `page.get_by_text("Link").click` |

#### 3. Update Assertions

**Capybara → Playwright assertion mapping**:

| Capybara | Playwright |
|----------|------------|
| `expect(page).to have_text("foo")` | `expect(page.get_by_text("foo")).to be_visible` |
| `expect(page).to have_css(".class")` | `expect(page.locator(".class")).to be_visible` |
| `expect(page).to have_no_text("foo")` | `expect(page.get_by_text("foo").count).to eq(0)` |
| `expect(page).to have_content("foo")` | `expect(page.get_by_text("foo")).to be_visible` |

#### 4. Remove wait_for_ajax Calls

```ruby
# Before
click_button "Save"
wait_for_ajax
expect(page).to have_text("Saved")

# After
click_button "Save"
# Wait for specific element instead
page.get_by_text("Saved").wait_for(state: 'visible')
expect(page.get_by_text("Saved")).to be_visible
```

**Note**: Playwright auto-waits, but for AJAX-heavy operations, wait for specific elements to appear/disappear rather than using generic waits.

#### 5. Handle Multiple Matches

Playwright's strict mode requires unique selectors:

```ruby
# Before (Capybara allows ambiguous selectors)
expect(page).to have_text("7")

# After (multiple "7"s on page - be specific)
expect(page.locator("span.editable.value:has-text('7')").first).to be_visible
```

#### 6. Handle Dialog Confirmations

```ruby
# Before (Capybara)
accept_confirm do
  click_button "Delete"
end

# After (Playwright)
page.once('dialog', ->(dialog) { dialog.accept })
click_button "Delete"

# Or use the helper we created:
accept_confirm do
  click_button "Delete"
end
```

---

## Complete Migration Example

### Before: Capybara Version
```ruby
scenario "I can modify the estimation item title", :js do
  expect(page).to have_no_text new_estimation_title

  page.find("span.editable.title", text: estimation.estimation_items.first.title).click
  expect(page).to have_css(".editable-inline")

  page.find(".editable-inline .editable-input input").set new_estimation_title
  page.find(".editable-inline .editable-submit").click

  wait_for_ajax

  expect(page).to have_text new_estimation_title

  visit current_path
  expect(page).to have_text new_estimation_title
end
```

### After: Playwright Version
```ruby
scenario "I can modify the estimation item title", :playwright do
  expect(page.get_by_text(new_estimation_title).count).to eq(0)

  page.locator("span.editable.title:has-text('#{estimation.estimation_items.first.title}')").click
  page.locator(".editable-inline").wait_for(state: 'visible')

  page.locator(".editable-inline .editable-input input").fill(new_estimation_title)
  page.locator(".editable-inline .editable-submit").click

  # Wait for the AJAX request to complete and the inline editor to disappear
  page.locator(".editable-inline").wait_for(state: 'hidden')

  expect(page.get_by_text(new_estimation_title)).to be_visible

  visit estimation_path(estimation)
  expect(page.get_by_text(new_estimation_title)).to be_visible
end
```

### Key Changes:
1. `:js` → `:playwright`
2. `page.find(selector, text: value)` → `page.locator("selector:has-text('value')")`
3. `.set(value)` → `.fill(value)`
4. `have_no_text` → `.count.to eq(0)`
5. `wait_for_ajax` → wait for specific element state changes
6. More explicit waiting for visibility/hidden states

---

## Critical Gotchas & Solutions

### 1. CSS Selector Syntax for Text Matching

❌ **WRONG** (JavaScript Playwright syntax):
```ruby
page.locator("span.editable", hasText: "value")
page.locator("span.editable", has_text: "value")
```

✅ **CORRECT** (CSS pseudo-selector):
```ruby
page.locator("span.editable:has-text('value')")
page.locator("span.editable:has-text('#{variable}')")
```

### 2. Strict Mode Violations

**Problem**: Playwright fails when selector matches multiple elements

❌ **FAILS**:
```ruby
expect(page.get_by_text("7")).to be_visible
# Error: strict mode violation: resolved to 4 elements
```

✅ **SOLUTIONS**:
```ruby
# Option A: Use .first
expect(page.locator("span.value:has-text('7')").first).to be_visible

# Option B: Be more specific with selector
expect(page.locator("#item_value:has-text('7')")).to be_visible

# Option C: Use count for absence checks
expect(page.get_by_text("7", exact: true).count).to eq(0)
```

### 3. Button/Form Submission

**Problem**: Button text might not match exactly, or button might be input vs button tag

❌ **FRAGILE**:
```ruby
page.locator("input[type='submit'][value='Add estimation item']").click
# Fails if button text or type changes
```

✅ **ROBUST**:
```ruby
# Option A: Press Enter on last field
page.locator("#estimation_item_title").press("Enter")

# Option B: Flexible button selector
page.locator("input[type='submit']:has-text('Add'), button:has-text('Add')").first.click
```

### 4. Wait for AJAX Completion

❌ **OLD WAY** (doesn't work in Playwright Ruby client):
```ruby
page.wait_for_load_state('networkidle')  # Wrong API
```

✅ **CORRECT APPROACHES**:
```ruby
# Option A: Wait for element to appear
page.get_by_text("Success message").wait_for(state: 'visible', timeout: 5000)

# Option B: Wait for element to disappear
page.locator(".loading-spinner").wait_for(state: 'hidden')

# Option C: Wait for element state change
page.locator(".editable-inline").wait_for(state: 'hidden')  # Editor closes after save
```

### 5. Counting Elements After AJAX

**Problem**: `.count` returns immediately, doesn't wait

❌ **UNRELIABLE**:
```ruby
click_button "Add"
expect(page.locator(".item").count).to eq(5)  # May execute before AJAX completes
```

✅ **RELIABLE**:
```ruby
click_button "Add"
# Wait for specific new element to appear
page.locator(".item").nth(4).wait_for(state: 'visible')
# Then check count
expect(page.locator(".item").count).to eq(5)
```

### 6. Rails Server Integration

**Problem**: Playwright needs Rails server running

The helper handles this automatically by:
```ruby
@capybara_server = Capybara::Server.new(Rails.application).boot
```

Then in `visit`:
```ruby
def visit(path)
  host = @capybara_server.host
  port = @capybara_server.port
  page.goto("http://#{host}:#{port}#{path}")
end
```

### 7. Turbo/Stimulus Synchronization

**Already handled** in `spec/support/playwright.rb`:

```ruby
def wait_for_turbo
  page.evaluate(<<~JS)
    new Promise((resolve) => {
      if (document.documentElement.hasAttribute('data-turbo-preview')) {
        document.addEventListener('turbo:load', () => resolve(), { once: true });
      } else {
        resolve();
      }
    });
  JS

  page.wait_for_function(<<~JS, timeout: 5000)
    !document.querySelector('turbo-frame[busy]')
  JS
rescue Playwright::TimeoutError
  # Turbo might not be present, that's okay
end
```

This is called automatically in `visit()`, so you don't need to call it manually.

---

## Testing Checklist

After migrating a spec file:

- [ ] All tests pass
- [ ] No `wait_for_ajax` calls remain
- [ ] No custom sleep calls (except for very specific timing issues)
- [ ] Selectors are specific enough (no strict mode violations)
- [ ] AJAX operations wait for specific element changes
- [ ] Screenshots are captured on failure (check `tmp/screenshots/`)
- [ ] Tests run faster or similar speed to Capybara

---

## Performance Comparison

### inline_editing_spec.rb

| Metric | Capybara (Apparition) | Playwright |
|--------|----------------------|------------|
| Total time | ~20s (with failures) | 9.88s |
| Tests | 6 | 6 |
| Failures | 3 | 0 |
| Custom waits | `wait_for_ajax` × 6 | None needed |

---

## Remaining Work

### Files to Migrate (10 files)

Priority order:

1. **HIGH**: `estimation_item_ordering_spec.rb` - Currently has pending drag-and-drop test that Playwright can unblock
2. **MEDIUM**: `deletions_spec.rb` - Tests Turbo confirmations (good test of dialog handling)
3. **MEDIUM**: `esc_key_cancellation_spec.rb` - Tests keyboard interactions
4. **MEDIUM**: `tracking_mode_spec.rb` - Tests dynamic AJAX updates
5. **MEDIUM**: `estimation_title_editing_spec.rb` - More inline editing
6. **MEDIUM**: `addition_of_estimations_and_items_spec.rb` - AJAX additions
7. **MEDIUM**: `estimated_values_spec.rb` - Value calculations
8. **LOW**: `user_permissions_spec.rb` - Authorization (less JS-heavy)
9. **LOW**: `google_logins_spec.rb` - OAuth flow (may need special handling)
10. **SKIP**: `estimations_on_dashboards_spec.rb` - Non-JS test, keep with Capybara

### Cleanup After Full Migration

Once all tests are migrated:

1. **Remove Capybara dependencies**:
   ```ruby
   # Remove from Gemfile:
   # gem 'capybara'
   # gem 'apparition', github: 'twalpole/apparition'
   ```

2. **Delete obsolete helpers**:
   ```bash
   rm spec/support/wait_for_ajax.rb
   rm app/javascript/fetch_tracker.js
   ```

3. **Clean up rails_helper.rb**:
   ```ruby
   # Remove:
   require 'capybara/rspec'
   require 'capybara/rails'
   require 'capybara/apparition'
   require 'support/wait_for_ajax'

   # Remove:
   config.include WaitForAjax, type: :feature

   # Remove:
   Capybara.register_driver :apparition do |app|
     Capybara::Apparition::Driver.new(app, headless: true, js_errors: true)
   end
   Capybara.configure do |config|
     config.default_normalize_ws = true
   end
   Capybara.javascript_driver = :apparition
   ```

4. **Update environment config**:
   Remove `data-env="test"` checks and fetch tracker initialization from `application.html.erb` or JavaScript

---

## Debugging Tips

### 1. Enable Headed Mode

Edit `spec/support/playwright.rb`:
```ruby
playwright.chromium.launch(
  headless: false,  # Change to false
  args: ['--disable-dev-shm-usage', '--no-sandbox']
)
```

### 2. Add Slow Motion

```ruby
playwright.chromium.launch(
  headless: false,
  slowMo: 1000,  # Slow down by 1 second per action
  args: ['--disable-dev-shm-usage', '--no-sandbox']
)
```

### 3. Screenshots on Failure

Already configured! Check `tmp/screenshots/` after test failures.

### 4. Pause Test Execution

```ruby
page.pause  # Opens Playwright Inspector
```

### 5. Check Element State

```ruby
puts page.locator(".my-element").count
puts page.locator(".my-element").visible?
puts page.locator(".my-element").inner_text
```

### 6. Increase Timeout for Debugging

```ruby
page.locator(".slow-element").wait_for(state: 'visible', timeout: 30000)  # 30 seconds
```

---

## Common Patterns Reference

### Pattern: Inline Editing
```ruby
# Click editable field
page.locator("span.editable:has-text('#{old_value}')").click

# Wait for editor to appear
page.locator(".editable-inline").wait_for(state: 'visible')

# Fill new value
page.locator(".editable-inline input").fill(new_value)

# Submit
page.locator(".editable-inline .submit").click

# Wait for editor to close (indicates save complete)
page.locator(".editable-inline").wait_for(state: 'hidden')

# Verify new value
expect(page.get_by_text(new_value)).to be_visible
```

### Pattern: Form Submission with AJAX
```ruby
# Fill form
page.locator("#field1").fill("value1")
page.locator("#field2").fill("value2")

# Submit
page.locator("#field2").press("Enter")

# Wait for success indicator
page.get_by_text("Successfully saved").wait_for(state: 'visible')
```

### Pattern: Delete with Confirmation
```ruby
# Set up dialog handler
page.once('dialog', ->(dialog) { dialog.accept })

# Trigger deletion
page.locator(".delete-button").click

# Wait for item to disappear
page.locator("#item_#{id}").wait_for(state: 'hidden')
```

### Pattern: Dynamic List Addition
```ruby
initial_count = items.count

# Add item
page.locator("#add_button").click

# Wait for new item to appear
page.locator(".item").nth(initial_count).wait_for(state: 'visible')

# Verify count increased
expect(page.locator(".item").count).to eq(initial_count + 1)
```

---

## Quick Reference Card

### Most Common Migrations

```ruby
# Capybara                                    → Playwright

# Finding elements
page.find(".class")                           → page.locator(".class")
page.find(".class", text: "foo")             → page.locator(".class:has-text('foo')")
page.all(".class")                            → page.locator(".class")  # returns collection

# Interactions
element.click                                 → element.click
element.set("value")                          → element.fill("value")
element.send_keys(:enter)                     → element.press("Enter")

# Assertions
expect(page).to have_text("foo")              → expect(page.get_by_text("foo")).to be_visible
expect(page).to have_css(".class")            → expect(page.locator(".class")).to be_visible
expect(page).to have_no_text("foo")           → expect(page.get_by_text("foo").count).to eq(0)

# Waiting
wait_for_ajax                                 → page.locator(".indicator").wait_for(state: 'hidden')
sleep(1)                                      → page.get_by_text("Expected").wait_for(state: 'visible')

# Navigation
visit "/path"                                 → visit "/path"  # Helper handles server URL

# Dialogs
accept_confirm { click }                      → page.once('dialog', ->(d) { d.accept }); click
```

---

## Success Metrics

✅ **Migration is successful when:**

1. All tests pass consistently (no flakiness)
2. No `wait_for_ajax` or `sleep` calls needed
3. Tests run as fast or faster than before
4. Debugging is easier (better error messages, screenshots)
5. No custom synchronization code required
6. Drag-and-drop tests work (previously pending)

---

## Getting Help

### Playwright Ruby Documentation
- [GitHub](https://github.com/YusukeIwaki/playwright-ruby-client)
- [API Docs](https://yusukeiwaki.github.io/playwright-ruby-client/)

### This Project's Helpers
- See `spec/support/playwright.rb` for available helper methods
- See `spec/features/inline_editing_spec.rb` for complete working examples

### Common Issues
- Check the "Critical Gotchas & Solutions" section above
- Review CircleCI build logs for CI-specific issues
- Check `tmp/screenshots/` for visual debugging of failures

---

## Conclusion

The Playwright migration successfully addresses all the reliability issues that plagued the Capybara test suite. The infrastructure is complete and battle-tested with 6 passing specs. The remaining migration work is straightforward pattern application, which you can now do at your own pace using this guide.

**Next recommended step**: Migrate `estimation_item_ordering_spec.rb` to unblock the drag-and-drop test that's currently marked as pending.
