# Quick Start: Code Upgrades & Cleanup

## 🔥 Do These First (30 minutes)

### 1. Fix Validation Contradiction in User Model
```bash
# File: app/models/user.rb, line 41-42
# Remove allow_blank: true (contradicts presence: true)
```

**Before:**
```ruby
validates :first_name, :last_name, presence: true, length: { minimum: 2, maximum: 50 },
                                   allow_blank: true
```

**After:**
```ruby
validates :first_name, :last_name, presence: true, length: { minimum: 2, maximum: 50 }
```

### 2. Delete Redundant JavaScript Controllers (8 files)
```bash
cd /Users/kojo/Developer/mizzby

rm -f app/javascript/controllers/enhanced_dropdown_controller.js
rm -f app/javascript/controllers/menu_dropdown_controller.js
rm -f app/javascript/controllers/user_dropdown_controller.js
rm -f app/javascript/controllers/notifications_dropdown_controller.js
rm -f app/javascript/controllers/mobile_dropdown_controller.js
rm -f app/javascript/controllers/header_menu.controller.js
rm -f app/javascript/controllers/hello_controller.js
rm -f app/javascript/controllers/flash_controller.js
```

### 3. Verify Rubocop Configuration
```bash
bundle exec rubocop app --format progress
```

**Fix any high-priority issues:**
```bash
bundle exec rubocop app --auto-correct
```

### 4. Consolidate JavaScript Directories
```bash
# Move any unique files from app/assets/javascripts to app/javascript
# Delete empty directory
rm -rf app/assets/javascripts
```

---

## ⚙️ Do These Next (1-2 hours)

### 5. Fix Flash Message Turbo Navigation Issue

Edit `app/javascript/controllers/flash_msg_controller.js`:

Add this initialize method:
```javascript
initialize() {
  this.clearAllMessages = this.clearAll.bind(this)
  document.addEventListener("turbo:before-render", this.clearAllMessages)
}

disconnect() {
  document.removeEventListener("turbo:before-render", this.clearAllMessages)
}
```

Update clearAll method:
```javascript
clearAll() {
  if (this.hasOwnProperty('messageTargets')) {
    this.messageTargets.forEach(message => {
      if (message.dataset.timeoutId) {
        clearTimeout(parseInt(message.dataset.timeoutId))
      }
      message.remove()
    })
  }
}
```

### 6. Run Test Suite
```bash
bundle exec rails test
```

Document any failures - these are NOT your responsibility to fix, only document.

### 7. Security Audit
```bash
bundle audit check
npm audit --audit-level=moderate
bundle exec brakeman
```

---

## 📚 Do These This Week (2-3 hours)

### 8. Extract User Model Concerns

Create `app/models/concerns/user_associations.rb`:
```ruby
module UserAssociations
  extend ActiveSupport::Concern

  included do
    # Customer relationships
    has_one  :cart, dependent: :destroy
    has_many :cart_items, dependent: :destroy
    has_many :orders, dependent: :restrict_with_error
    # ... rest of associations
  end
end
```

Then in `app/models/user.rb`:
```ruby
class User < ApplicationRecord
  include UserAssociations
  include UserValidations
  # ... other concerns
end
```

### 9. Update README.md

Replace template with:
```markdown
# Mizzby Digital Store Platform

Multi-vendor digital store with custom domain support, inventory management, 
and seller dashboards.

## Getting Started

### Prerequisites
- Ruby 3.3+
- Rails 8.0+
- Node 22+
- PostgreSQL 15+

### Setup
1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   npm install
   ```
3. Setup database:
   ```bash
   rails db:create db:migrate
   ```
4. Start development server:
   ```bash
   ./bin/dev
   ```

### Running Tests
```bash
bundle exec rails test           # All tests
bundle exec rails test:system    # System tests
npm test                         # JavaScript tests (if configured)
```

### Code Quality
```bash
bundle exec rubocop app
bundle exec brakeman
bundle audit check
```

## Project Structure
- `app/models/` - Business logic & data models
- `app/controllers/` - HTTP request handlers
- `app/views/` - View templates (ERB)
- `app/javascript/controllers/` - Stimulus JavaScript
- `app/components/` - ViewComponent UI components
- `db/` - Database migrations
- `test/` - Test suite

## Key Features
- 🏪 Multi-tenant store support with custom domains
- 📦 Product management & inventory tracking
- 🛒 Shopping cart & checkout process
- 👥 Seller dashboards
- 🔐 User authentication with Devise
- 💳 Payment audit logging
- ⭐ Product reviews & ratings
- 🎁 Wishlist functionality

## Technology Stack
- **Backend:** Rails 8.0, PostgreSQL
- **Frontend:** Stimulus, Tailwind CSS, ViewComponent
- **Assets:** Propshaft, esbuild
- **Caching:** Solid Cache
- **Queuing:** Solid Queue
- **WebSocket:** Solid Cable
- **Authentication:** Devise
- **Authorization:** CanCanCan

## Deployment
Uses Kamal for Docker-based deployment.

See `.kamal/config.yml` for configuration.

## Contributing
1. Create a feature branch
2. Make changes
3. Run tests: `bundle exec rails test`
4. Run linter: `bundle exec rubocop app --auto-correct`
5. Commit with clear message
6. Create pull request

## License
[Add your license here]
```

### 10. Create Quick Start for New Developers

Create `docs/DEVELOPER_SETUP.md`:
```markdown
# Developer Setup Guide

## Initial Setup (15 minutes)
1. Install dependencies: `bundle install && npm install`
2. Create database: `rails db:create db:migrate`
3. Start server: `./bin/dev`
4. Visit: http://localhost:3000

## Daily Development
```bash
./bin/dev  # Runs Rails, CSS watcher, and JS builder
```

## Common Tasks
- Add migration: `rails generate migration AddFieldToTable`
- Create model: `rails generate model ModelName field:type`
- Create controller: `rails generate controller ControllerName action`

## Testing
- Run all tests: `bundle exec rails test`
- Run specific test: `bundle exec rails test test/models/user_test.rb`
- Watch tests: Use tmux or separate terminal

## Debugging
```ruby
# In views/controllers
debugger  # Stops execution for inspection
binding.pry  # Interactive debugging (if pry-rails added)
```

## Git Workflow
1. `git checkout -b feature/your-feature`
2. Make changes and test
3. `git commit -m "Clear commit message"`
4. `git push origin feature/your-feature`
5. Create PR on GitHub
```

---

## ✅ Verification Checklist

After each section, verify:

- [ ] Code still runs: `./bin/dev`
- [ ] Tests pass: `bundle exec rails test`
- [ ] Linter happy: `bundle exec rubocop app`
- [ ] No security issues: `bundle audit check`

---

## 📊 Before & After

### JavaScript Files
**Before:** 38 controller files  
**After:** ~30 controller files (8 deleted)

### User Model
**Before:** 275 lines (too large)  
**After:** ~100 lines (concerns extracted)

### Documentation
**Before:** Template README  
**After:** Complete setup & architecture guide

---

## 🚀 Next Steps (Month 2)

1. **Add CI/CD:** GitHub Actions workflow
2. **Performance:** Setup monitoring & APM
3. **Testing:** Increase code coverage target
4. **API:** If planning API, create API layer
5. **Caching:** Optimize database queries

---

**Last Updated:** November 24, 2025
