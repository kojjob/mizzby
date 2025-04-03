# JavaScript Cleanup Guide

This document outlines the JavaScript files that should be removed or consolidated to improve the code organization and prevent bugs like the flash message persistence issue.

## Files to Delete

These files are redundant or deprecated and should be deleted:

1. `/app/assets/javascripts/controllers/flash_controller.js` - Outdated implementation
2. `/app/javascript/controllers/header_menu_controller.js` - Commented out (replaced by header_menu.controller.js)
3. `/app/javascript/examples/flash_message_example.js` - Example file not needed in production

## Directory Consolidation

The project currently has JavaScript files spread across two directories:
- `/app/assets/javascripts`
- `/app/javascript`

### Recommended Approach:

1. **Choose one location**: The `/app/javascript` directory is the standard Rails 7 location.
2. **Move unique files**: Any unique files from `/app/assets/javascripts` should be moved to `/app/javascript`.
3. **Update references**: Update any import statements or script tags.
4. **Phase out old directory**: Once consolidated, the `/app/assets/javascripts` directory can be removed.

## Specific Duplications

These files exist in both directories and should be consolidated:
- `header.js`
- `header_dropdowns.js`
- `application.js`
- `alpine_init.js`
- `tab_helper.js`

## Additional Actions

1. Remove the stimulus initializer from assets if importing via importmaps:
   - `/app/assets/javascripts/stimulus_initializer.js`

2. Fix naming inconsistencies:
   - Controllers should follow a consistent naming pattern (`snake_case_controller.js` is the Rails convention).
   - Rename `header_menu.controller.js` to `header_menu_controller.js` and update imports.

## Implementation Strategy

1. Create a new branch for this cleanup work
2. Make changes incrementally, testing after each step
3. Pay special attention to the application entry points and controller registrations
4. Test thoroughly across different pages to ensure nothing breaks
