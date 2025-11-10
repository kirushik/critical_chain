# Playwright Quick Reference Card

## 🎯 Most Common Conversions

### Finding Elements
```ruby
# Capybara → Playwright
find(".class")                    → page.locator(".class")
find(".class", text: "foo")       → page.locator(".class:has-text('foo')")
find("#id")                       → page.locator("#id")
all(".items")                     → page.locator(".items")  # Collection
```

### Interactions
```ruby
# Capybara → Playwright
element.click                     → element.click
element.set("value")              → element.fill("value")
element.send_keys(:enter)         → element.press("Enter")
click_button "Submit"             → page.locator("#field").press("Enter")
click_link "Link"                 → page.get_by_text("Link").click
```

### Assertions
```ruby
# Capybara → Playwright
expect(page).to have_text("foo")        → expect(page.get_by_text("foo")).to be_visible
expect(page).to have_css(".class")      → expect(page.locator(".class")).to be_visible
expect(page).to have_no_text("foo")     → expect(page.get_by_text("foo").count).to eq(0)
```

### Waiting
```ruby
# Capybara → Playwright
wait_for_ajax                     → page.locator(".loading").wait_for(state: 'hidden')
sleep(1)                          → page.get_by_text("Expected").wait_for(state: 'visible')
```

---

## ⚠️ Critical Syntax Rules

### ✅ Correct: CSS Pseudo-Selector
```ruby
page.locator("span:has-text('foo')")
page.locator(".editable:has-text('#{variable}')")
```

### ❌ Wrong: JavaScript API
```ruby
page.locator("span", hasText: "foo")      # ❌ Wrong
page.locator("span", has_text: "foo")     # ❌ Wrong
```

---

## 🔧 Common Patterns

### Pattern: Inline Editing
```ruby
page.locator("span.editable:has-text('#{old}')").click
page.locator(".editable-inline").wait_for(state: 'visible')
page.locator(".editable-inline input").fill(new_value)
page.locator(".editable-inline .submit").click
page.locator(".editable-inline").wait_for(state: 'hidden')
expect(page.get_by_text(new_value)).to be_visible
```

### Pattern: Form Submit
```ruby
page.locator("#field1").fill("value")
page.locator("#field2").press("Enter")
page.get_by_text("Success").wait_for(state: 'visible')
```

### Pattern: Delete with Confirm
```ruby
page.once('dialog', ->(dialog) { dialog.accept })
page.locator(".delete-button").click
page.locator("#item").wait_for(state: 'hidden')
```

### Pattern: AJAX List Add
```ruby
initial = items.count
page.locator("#add").click
page.locator(".item").nth(initial).wait_for(state: 'visible')
expect(page.locator(".item").count).to eq(initial + 1)
```

---

## 🐛 Top 5 Errors & Fixes

### 1. "unknown keyword: :has_text"
```ruby
# ✅ Fix: Use CSS syntax
page.locator(".class:has-text('foo')")
```

### 2. "strict mode violation"
```ruby
# ✅ Fix: Use .first or be more specific
page.locator(".class:has-text('foo')").first
```

### 3. "Timeout exceeded" on button
```ruby
# ✅ Fix: Press Enter instead
page.locator("#field").press("Enter")
```

### 4. "wrong number of arguments" at wait_for_load_state
```ruby
# ✅ Fix: Wait for specific element
page.locator(".loading").wait_for(state: 'hidden')
```

### 5. "net::ERR_CONNECTION_REFUSED"
```ruby
# ✅ Fix: Check spec/support/playwright.rb has server boot
@capybara_server = Capybara::Server.new(Rails.application).boot
```

---

## 🎯 Migration Checklist

- [ ] Change `:js` → `:playwright`
- [ ] Update selectors to use `:has-text('...')`
- [ ] Replace `wait_for_ajax` with element waits
- [ ] Remove `sleep` calls
- [ ] Test passes 3+ times
- [ ] No strict mode errors

---

## 🚀 Quick Commands

```bash
# Run single file
bundle exec rspec spec/features/my_spec.rb

# Run single test
bundle exec rspec spec/features/my_spec.rb:17

# Run all Playwright tests
bundle exec rspec --tag playwright

# Debug with headed browser
# (Edit spec/support/playwright.rb: headless: false)
```

---

## 📞 When Stuck

1. Check `PLAYWRIGHT_TROUBLESHOOTING.md`
2. Look at `spec/features/inline_editing_spec.rb`
3. Read `PLAYWRIGHT_MIGRATION_GUIDE.md`
4. Take screenshot: `page.screenshot(path: 'tmp/debug.png')`
5. Run headed: `headless: false` in playwright.rb

---

## ✨ Remember

- **Playwright is strict** - selectors must be unique
- **Playwright auto-waits** - don't add sleeps
- **Use specific waits** - wait for element changes, not time
- **When in doubt** - check the working example

---

**Files:**
- 📚 Full Guide: `PLAYWRIGHT_MIGRATION_GUIDE.md`
- 🐛 Errors: `PLAYWRIGHT_TROUBLESHOOTING.md`
- 📊 Status: `PLAYWRIGHT_MIGRATION_SUMMARY.md`
- ✅ Example: `spec/features/inline_editing_spec.rb`
