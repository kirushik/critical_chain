# Playwright Troubleshooting Cheat Sheet

Quick reference for common issues when migrating tests to Playwright.

---

## Error: "unknown keyword: :has_text"

**Symptom:**
```
ArgumentError: unknown keyword: :has_text
```

**Cause:** Using JavaScript Playwright syntax instead of CSS pseudo-selectors

**Fix:**
```ruby
# ❌ Wrong
page.locator("span.editable", has_text: "foo")
page.locator("span.editable", hasText: "foo")

# ✅ Correct
page.locator("span.editable:has-text('foo')")
page.locator("span.editable:has-text('#{variable}')")
```

---

## Error: "strict mode violation: resolved to N elements"

**Symptom:**
```
Playwright::Error: strict mode violation: get_by_text("7") resolved to 4 elements
```

**Cause:** Selector matches multiple elements, Playwright requires unique targeting

**Fix:**
```ruby
# ❌ Ambiguous
expect(page.get_by_text("7")).to be_visible

# ✅ Use .first
expect(page.locator("span.value:has-text('7')").first).to be_visible

# ✅ Or be more specific
expect(page.locator("#specific_id:has-text('7')")).to be_visible

# ✅ Or check count
expect(page.get_by_text("7").count).to eq(3)  # Expect 3 matches
```

---

## Error: "wrong number of arguments (given 1, expected 0)"

**Symptom:**
```
ArgumentError: wrong number of arguments (given 1, expected 0)
# at wait_for_load_state
```

**Cause:** `wait_for_load_state` doesn't take arguments in Ruby client

**Fix:**
```ruby
# ❌ Wrong (JavaScript API)
page.wait_for_load_state('networkidle')

# ✅ Correct (wait for specific elements instead)
page.locator(".loading").wait_for(state: 'hidden')
page.get_by_text("Loaded").wait_for(state: 'visible')
```

---

## Error: "Timeout 10000ms exceeded" on button click

**Symptom:**
```
Playwright::TimeoutError: Timeout 10000ms exceeded.
Call log:
  - waiting for locator("input[type='submit'][value='Add item']")
```

**Cause:** Button selector doesn't match actual HTML element

**Fix:**
```ruby
# ❌ Too specific
page.locator("input[type='submit'][value='Add item']").click

# ✅ Press Enter instead
page.locator("#last_field").press("Enter")

# ✅ Or use flexible selector
page.locator("input[type='submit']:has-text('Add'), button:has-text('Add')").first.click

# ✅ Or debug to find actual element
puts page.locator("form").inner_html  # Inspect form structure
```

---

## Error: "net::ERR_CONNECTION_REFUSED"

**Symptom:**
```
Playwright::Error: net::ERR_CONNECTION_REFUSED at http://127.0.0.1/path
```

**Cause:** Rails server not running or visit() not using correct port

**Fix:** Verify `spec/support/playwright.rb` has:
```ruby
# In around block
@capybara_server = Capybara::Server.new(Rails.application).boot

# In visit method
def visit(path)
  host = @capybara_server.host
  port = @capybara_server.port
  page.goto("http://#{host}:#{port}#{path}")
  wait_for_turbo
end
```

---

## Test Passes Locally, Fails in CI

**Possible Causes & Fixes:**

### 1. Timing Issues
```ruby
# Add explicit waits for critical elements
page.locator(".important").wait_for(state: 'visible', timeout: 10000)
```

### 2. Missing Playwright Installation
Check `.circleci/config.yml`:
```yaml
- run:
    name: Install Playwright browsers
    command: npx playwright install chromium --with-deps
```

### 3. Screenshot Directory
```bash
# Ensure tmp/screenshots exists or is created in test
FileUtils.mkdir_p('tmp/screenshots')
```

### 4. Database State
```ruby
# Verify database_cleaner is using truncation for :playwright tests
# In spec/support/database_cleaner.rb:
config.before(:each, :playwright => true) do
  DatabaseCleaner.strategy = :truncation
end
```

---

## Element Not Visible

**Symptom:**
```
expected `#<Playwright::Locator>.visible?` to be truthy, got false
```

**Debug Steps:**

### 1. Check if element exists
```ruby
puts page.locator(".my-element").count  # Should be > 0
```

### 2. Check element state
```ruby
puts page.locator(".my-element").visible?
puts page.locator(".my-element").inner_text
puts page.locator(".my-element").get_attribute("class")
```

### 3. Take screenshot
```ruby
page.screenshot(path: 'tmp/debug.png')
```

### 4. Wait longer
```ruby
page.locator(".my-element").wait_for(state: 'visible', timeout: 30000)
```

### 5. Check parent visibility
```ruby
# Element might be hidden by parent
page.locator(".parent-container").wait_for(state: 'visible')
```

---

## AJAX Request Not Completing

**Symptom:** Test times out waiting for element after AJAX action

**Debug:**

### 1. Check console for JS errors
```ruby
# Enable headed mode and check browser console
# In spec/support/playwright.rb:
playwright.chromium.launch(headless: false, ...)
```

### 2. Wait for specific indicator
```ruby
# ❌ Don't rely on generic waits
sleep(2)

# ✅ Wait for specific element change
page.locator(".loading-spinner").wait_for(state: 'hidden')
page.locator(".success-message").wait_for(state: 'visible')
```

### 3. Check if Turbo/Stimulus loaded
```ruby
# Add to test:
wait_for_turbo
wait_for_stimulus
```

### 4. Verify form submits
```ruby
# Try pressing Enter instead of clicking button
page.locator("#form_field").press("Enter")
```

---

## Drag and Drop Not Working

**For HTML5 Drag API:**

```ruby
# Get the source and target elements
source = page.locator(".draggable-item")
target = page.locator(".drop-zone")

# Use Playwright's drag_to
source.drag_to(target)

# Or manual drag with mouse
source.hover
page.mouse.down
target.hover
page.mouse.up
```

**For jQuery UI Sortable:**

```ruby
# May need to simulate with mouse events
item = page.locator(".sortable-item").nth(2)
target = page.locator(".sortable-item").nth(0)

# Get bounding boxes
item_box = item.bounding_box
target_box = target.bounding_box

# Perform drag
page.mouse.move(item_box['x'] + item_box['width']/2, item_box['y'] + item_box['height']/2)
page.mouse.down
page.mouse.move(target_box['x'] + target_box['width']/2, target_box['y'] + target_box['height']/2)
page.mouse.up
```

---

## Cannot Find Element by Text

**Symptom:** Element exists but `get_by_text` or `:has-text()` doesn't find it

**Causes & Fixes:**

### 1. Text is split across elements
```ruby
# ❌ Text might be "Hello" + " " + "World" in separate spans
page.get_by_text("Hello World")

# ✅ Use partial match
page.locator("*:has-text('Hello')").locator("*:has-text('World')")
```

### 2. Text has extra whitespace
```ruby
# ✅ Use regex or normalize
page.locator("div:has-text('Expected')")  # Matches with extra spaces
```

### 3. Text is in input value
```ruby
# ❌ get_by_text doesn't find input values
page.get_by_text("input value")

# ✅ Use locator with value attribute
page.locator("input[value='input value']")
```

### 4. Text case doesn't match
```ruby
# :has-text is case-insensitive by default, but exact match is case-sensitive
page.get_by_text("hello", exact: false)  # Case insensitive
page.get_by_text("Hello", exact: true)   # Case sensitive
```

---

## Test Hangs Indefinitely

**Possible Causes:**

### 1. Waiting for element that never appears
```ruby
# Add timeout
page.locator(".never-appears").wait_for(state: 'visible', timeout: 5000)
# Will raise TimeoutError after 5s instead of hanging
```

### 2. Dialog blocking execution
```ruby
# Always set dialog handler before action that triggers it
page.once('dialog', ->(dialog) { dialog.accept })
click_button "Delete"  # Triggers dialog
```

### 3. Infinite loop in JavaScript
```ruby
# Check browser console in headed mode
playwright.chromium.launch(headless: false, ...)
```

---

## Quick Debugging Commands

### Enable Headed Mode Temporarily
```ruby
# In spec/support/playwright.rb, change:
playwright.chromium.launch(headless: false, slowMo: 500, ...)
```

### Pause Test at Specific Point
```ruby
page.pause  # Opens Playwright Inspector
```

### Print Element Info
```ruby
element = page.locator(".my-element")
puts "Count: #{element.count}"
puts "Visible: #{element.visible? rescue 'error'}"
puts "Text: #{element.inner_text rescue 'error'}"
puts "HTML: #{element.inner_html rescue 'error'}"
```

### Print All Matching Elements
```ruby
page.locator(".item").all.each_with_index do |el, i|
  puts "#{i}: #{el.inner_text}"
end
```

### Take Screenshot at Any Point
```ruby
page.screenshot(path: "tmp/debug_#{Time.now.to_i}.png")
```

### Run Single Test
```bash
bundle exec rspec spec/features/my_spec.rb:42  # Line number
```

### Run Without Coverage (Faster)
```bash
COVERAGE=false bundle exec rspec spec/features/my_spec.rb
```

---

## Performance Issues

### Tests Running Slow

**Causes & Solutions:**

### 1. Too many screenshots
```ruby
# Only screenshot on failure (already configured)
# Don't add extra screenshots unless debugging
```

### 2. Not using browser reuse
```ruby
# Our setup already reuses browser within test
# But launches new for each test (isolation)
# This is correct behavior
```

### 3. Unnecessary waits
```ruby
# ❌ Don't use fixed sleeps
sleep(5)

# ✅ Use targeted waits
page.locator(".indicator").wait_for(state: 'hidden', timeout: 5000)
```

### 4. Slow selectors
```ruby
# ❌ Complex CSS selectors
page.locator("body > div > section > div.container > div.row > span.text")

# ✅ Use ID or specific class
page.locator("#target_element")
page.locator(".specific-class")
```

---

## Environment-Specific Issues

### macOS
- Use system Chrome instead of downloading if needed
- Playwright browsers install to `~/Library/Caches/ms-playwright/`

### Linux/CI
- May need `--with-deps` flag: `npx playwright install chromium --with-deps`
- Check for missing system libraries
- Verify headless mode works: `chromium --headless` should run

### Docker
- Add to Dockerfile:
```dockerfile
RUN npx playwright install chromium --with-deps
```

---

## Getting More Help

1. **Check screenshots**: `tmp/screenshots/` after failures
2. **Run in headed mode**: See browser actions visually
3. **Check CircleCI artifacts**: Screenshots uploaded to CI
4. **Consult main guide**: `PLAYWRIGHT_MIGRATION_GUIDE.md`
5. **Playwright Ruby docs**: https://github.com/YusukeIwaki/playwright-ruby-client
6. **Working example**: See `spec/features/inline_editing_spec.rb`

---

## Remember

- Playwright is **strict** - selectors must be unique
- Playwright **auto-waits** - don't add unnecessary sleeps
- Playwright is **modern** - use it to test modern web features
- When in doubt, **wait for specific elements**, not generic timers
