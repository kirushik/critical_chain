# Bulma CSS Migration Plan - Critical Chain Estimator

## Executive Summary

This document outlines a thoughtful migration from Bootstrap 4.6.2 to BulmaCSS 1.0.4, focusing on **meaningful UX improvements** rather than a simple 1:1 port. The migration leverages Bulma's modern flexbox architecture, cleaner semantics, and superior mobile responsiveness to enhance the Critical Chain estimation tool.

---

## Current State Analysis

### Technical Stack
- **Rails**: 7.2.3 with Propshaft asset pipeline
- **JavaScript**: Importmap-rails (no bundler)
- **CSS Framework**: Bootstrap 4.6.2 (CDN)
- **Icons**: Font Awesome 6.7.0 (CDN)
- **Interactivity**: Hotwire (Turbo + Stimulus)
- **Custom CSS**: ~100 lines (minimal)

### Design Intentions Observed

1. **Color-Coded Information Hierarchy**
   - 🟢 Green (success) = Estimated sum
   - 🔵 Blue (info) = Buffer amount
   - 🟡 Yellow (warning) = Total estimate
   - Gray (muted) = Secondary information

2. **Inline Editing Philosophy**
   - Click-to-edit fields with dashed underlines
   - Minimal friction for rapid data entry
   - Visual feedback (pencil icon on hover, highlight flash on update)

3. **Drag-and-Drop Prioritization**
   - Subtle grip handles
   - Low-friction task reordering
   - Visual feedback during drag operations

4. **Mode Switching**
   - Toggle between estimation and tracking modes
   - Different UI layouts optimized for each mode

5. **Minimalist, Data-Focused Interface**
   - No unnecessary decoration
   - High information density without clutter
   - Fast, keyboard-friendly workflows

---

## Why Bulma? Strategic Advantages

### 1. **CSS-Only Framework** ✅
- No JavaScript dependencies (perfect for Hotwire)
- Works seamlessly with Stimulus controllers
- Smaller bundle size

### 2. **Modern Flexbox Architecture** ✅
- Better responsive behavior out-of-the-box
- More intuitive layout system
- Improved mobile experience

### 3. **Semantic Class Names** ✅
- `.is-success`, `.is-info`, `.is-warning` vs `.text-success`, `.alert-info`
- More readable and maintainable code
- Better developer experience

### 4. **Superior Mobile Responsiveness** ✅
- Mobile-first design philosophy
- Better touch targets
- Improved table responsiveness (`.table-container`)

### 5. **Cleaner, Modern Aesthetic** ✅
- Less "Bootstrap-y" look
- More customizable color palette
- Modern, clean spacing system

---

## Integration Strategy: Rails-Native CDN Approach

### Rationale
Given the current architecture (Propshaft + Importmap, no Node.js), the most Rails-native approach is:

**CDN Integration** - exactly like current Bootstrap setup:
- ✅ No build step required
- ✅ No Node.js/npm dependencies
- ✅ Works perfectly with Propshaft
- ✅ Fast CDN delivery (jsDelivr)
- ✅ Easy to maintain and upgrade
- ✅ Consistent with current architecture

### Implementation
```erb
<!-- Replace Bootstrap CDN -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/[email protected]/css/bulma.min.css">

<!-- Keep Font Awesome (works great with Bulma) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.0/css/all.min.css">

<!-- Custom application.css for project-specific styles -->
<%= stylesheet_link_tag 'application', media: 'all', 'data-turbo-track' => 'reload' %>
```

---

## Component Migration Map

### 1. Layout & Navigation

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<div class="navbar navbar-dark bg-dark">
  <a href="/" class="navbar-brand">Buffer estimator</a>
  <ul class="nav navbar-nav navbar-right">...</ul>
</div>

<!-- AFTER: Bulma -->
<nav class="navbar is-dark" role="navigation">
  <div class="navbar-brand">
    <a class="navbar-item" href="/">
      <strong>Buffer estimator</strong>
    </a>
  </div>
  <div class="navbar-menu">
    <div class="navbar-end">...</div>
  </div>
</nav>
```

**UX Improvements:**
- Proper semantic `<nav>` element
- Built-in mobile hamburger menu support
- Better accessibility (ARIA roles)
- Cleaner visual hierarchy

---

### 2. Flash Messages

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<div class="alert alert-info" role="alert"><%= notice %></div>
<div class="alert alert-warning" role="alert"><%= alert %></div>

<!-- AFTER: Bulma -->
<div class="notification is-info is-light">
  <button class="delete"></button>
  <%= notice %>
</div>
<div class="notification is-warning is-light">
  <button class="delete"></button>
  <%= alert %>
</div>
```

**UX Improvements:**
- Softer `is-light` variants (less aggressive colors)
- Built-in close button styling
- Better visual design (rounded corners, modern spacing)

---

### 3. Grid System

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<div class="container">
  <div class="row">
    <div class="col-md-6">...</div>
    <div class="col-md-5 offset-md-1">...</div>
  </div>
</div>

<!-- AFTER: Bulma -->
<div class="container">
  <div class="columns">
    <div class="column is-half">...</div>
    <div class="column is-5 is-offset-1">...</div>
  </div>
</div>
```

**UX Improvements:**
- More intuitive naming (`.is-half` vs `.col-md-6`)
- Better mobile stacking behavior
- Simplified responsive breakpoint system

---

### 4. Forms

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<div class="input-group">
  <input type="text" class="form-control" placeholder="Value">
  <div class="input-group-append">
    <button class="btn btn-success">Add</button>
  </div>
</div>

<!-- AFTER: Bulma -->
<div class="field has-addons">
  <div class="control is-expanded">
    <input class="input" type="text" placeholder="Value">
  </div>
  <div class="control">
    <button class="button is-success">
      <span class="icon">
        <i class="fa-solid fa-circle-plus"></i>
      </span>
    </button>
  </div>
</div>
```

**UX Improvements:**
- Better semantic structure (`.field` → `.control`)
- More consistent spacing
- Built-in icon support (`.icon` wrapper)
- Better accessibility structure

---

### 5. Tables

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<table class="table table-hover">
  <tbody>...</tbody>
</table>

<!-- AFTER: Bulma -->
<div class="table-container">
  <table class="table is-hoverable is-fullwidth">
    <tbody>...</tbody>
  </table>
</div>
```

**UX Improvements:**
- `.table-container` for mobile horizontal scrolling
- More modifier options (`.is-striped`, `.is-narrow`, `.is-hoverable`)
- Better responsive behavior on small screens
- Cleaner hover states

---

### 6. Buttons

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<button class="btn btn-success">Create</button>
<button class="btn btn-link">Cancel</button>
<button class="btn btn-outline-dark">Toggle</button>

<!-- AFTER: Bulma -->
<button class="button is-success">Create</button>
<button class="button is-text">Cancel</button>
<button class="button is-outlined">Toggle</button>
```

**UX Improvements:**
- Cleaner, more modern button designs
- Better touch targets (more padding)
- Consistent sizing across all button types

---

### 7. List Groups

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<div class="list-group">
  <div class="list-group-item">...</div>
</div>

<!-- AFTER: Bulma -->
<div class="box">
  <div class="content">...</div>
</div>
<!-- OR -->
<div class="panel">
  <a class="panel-block">...</a>
</div>
```

**UX Improvements:**
- `.box` provides cleaner card-like containers
- `.panel` for more structured list displays
- Better shadow and spacing defaults
- More modern visual appearance

---

### 8. Text Utilities

#### Bootstrap → Bulma
```html
<!-- BEFORE: Bootstrap -->
<span class="text-success">Sum</span>
<span class="text-info">Buffer</span>
<span class="text-warning">Total</span>
<span class="text-muted">Optional</span>
<span class="text-right">Aligned</span>

<!-- AFTER: Bulma -->
<span class="has-text-success">Sum</span>
<span class="has-text-info">Buffer</span>
<span class="has-text-warning">Total</span>
<span class="has-text-grey">Optional</span>
<span class="has-text-right">Aligned</span>
```

**UX Improvements:**
- More semantic naming (`has-text-*` is clearer)
- Expanded color palette with more shades
- Better color contrast ratios (accessibility)

---

## Custom CSS Updates Required

### Editable Fields
```css
/* Keep existing functionality, update class references */
.editable-field .editable-display {
    border-bottom: 1px dashed hsl(0, 0%, 60%); /* Use Bulma color variables */
}

/* Update input-group references to field/control */
.editable-form .field {
    width: auto;
}
```

### Drag Handles
```css
/* Keep existing drag handle styles */
.drag-handle {
    cursor: move;
    width: 30px;
}
```

### Turbo Progress Bar
```css
/* Update to use Bulma's primary color */
.turbo-progress-bar {
    height: 5px;
    background-color: hsl(204, 86%, 53%); /* Bulma's $blue */
}
```

---

## Migration Sequence

### Phase 1: Foundation (Non-Breaking)
1. ✅ Add Bulma CDN alongside Bootstrap (both coexist)
2. ✅ Update custom CSS to use Bulma color variables
3. ✅ Test that nothing breaks visually

### Phase 2: Layout & Navigation
1. Migrate `application.html.erb` layout
2. Update navbar structure
3. Migrate flash messages to notifications
4. Update container/grid system
5. **Test thoroughly**

### Phase 3: Forms & Inputs
1. Migrate estimation item creation form
2. Update inline editing fields
3. Migrate toggle buttons
4. Update form validation states
5. **Test thoroughly**

### Phase 4: Tables & Data Display
1. Migrate estimation items table
2. Add responsive `.table-container`
3. Update results display
4. Migrate estimation list (index page)
5. **Test thoroughly**

### Phase 5: Cleanup & Optimization
1. Remove Bootstrap CDN
2. Remove unused custom CSS
3. Update deprecated class names
4. Add mobile hamburger menu JavaScript (small snippet)
5. Final responsive testing
6. **Commit and push**

---

## JavaScript Requirements

Bulma is CSS-only, but needs minimal JavaScript for:

### Mobile Navbar Toggle
```javascript
// Add to app/javascript/controllers/navbar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("is-active")
  }
}
```

```erb
<!-- In navbar -->
<div class="navbar-burger" data-navbar-target="burger" data-action="click->navbar#toggle">
  <span></span>
  <span></span>
  <span></span>
</div>
```

### Notification Close Buttons
```javascript
// Add to app/javascript/controllers/notification_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    this.element.remove()
  }
}
```

---

## Design Enhancements (Beyond 1:1 Port)

### 1. **Improved Color Palette**
Use Bulma's extended color system:
- `is-success` (green) for positive values
- `is-info` (blue) for buffer/informational
- `is-warning` (yellow) for totals/attention
- `is-danger` (red) for errors/deletions
- `is-grey` for muted content

### 2. **Better Spacing**
Leverage Bulma's spacing helpers:
- `mt-4`, `mb-5`, `px-3` for consistent margins/padding
- Better visual rhythm
- More breathing room on mobile

### 3. **Enhanced Forms**
- Add `.is-loading` state to buttons during submission
- Use `.help` for field hints
- Add `.icon` containers for better icon alignment
- Use `.is-danger` for validation errors

### 4. **Responsive Tables**
- Wrap tables in `.table-container` for horizontal scroll
- Consider `.is-narrow` for more compact displays
- Use `.is-fullwidth` for better mobile layouts

### 5. **Improved Cards**
- Use `.box` instead of `.list-group-item` for cleaner cards
- Better shadows and hover states
- More modern card aesthetics

### 6. **Better Typography**
- Use Bulma's `.title` and `.subtitle` classes
- Better heading hierarchy (`.is-1` through `.is-6`)
- Improved readability with better line-heights

---

## Testing Checklist

- [ ] Desktop Chrome/Firefox/Safari
- [ ] Mobile Safari (iOS)
- [ ] Mobile Chrome (Android)
- [ ] Tablet responsive breakpoints
- [ ] Inline editing functionality
- [ ] Drag-and-drop sorting
- [ ] Form submissions
- [ ] Mode toggles
- [ ] Flash message dismissal
- [ ] Mobile navbar toggle
- [ ] Turbo navigation
- [ ] Keyboard accessibility
- [ ] Screen reader compatibility

---

## Rollback Plan

If issues arise:
1. Revert layout file changes
2. Re-enable Bootstrap CDN
3. Restore original custom CSS
4. Test that original functionality works
5. Git reset to previous commit

---

## Success Metrics

- ✅ Zero functionality lost
- ✅ Improved mobile experience
- ✅ Better accessibility scores
- ✅ Cleaner, more maintainable code
- ✅ Faster perceived performance
- ✅ Modern, professional appearance
- ✅ No new dependencies added

---

## Next Steps

1. Review this plan with team/stakeholders
2. Create feature branch: `feature/bulma-migration`
3. Implement Phase 1 (foundation)
4. Commit frequently with descriptive messages
5. Test thoroughly after each phase
6. Deploy to staging for QA
7. Merge to main after approval

---

## Additional Resources

- [Bulma Documentation](https://bulma.io/documentation/)
- [Bulma vs Bootstrap Comparison](https://bulma.io/alternative-to-bootstrap/)
- [Bulma Color Helpers](https://bulma.io/documentation/helpers/color-helpers/)
- [Bulma Responsiveness](https://bulma.io/documentation/overview/responsiveness/)
- [Rails Propshaft Guide](https://github.com/rails/propshaft)
