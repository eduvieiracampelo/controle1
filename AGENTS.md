# AGENTS.md - Coding Guidelines for Controle

This is a Rails 8.1 application using SQLite, Turbo, Stimulus, and Kamal deployment.

## Build/Lint/Test Commands

### Development
```bash
bin/rails server          # Start development server
bin/setup                 # Install dependencies and prepare database
bin/dev                   # Start development server with foreman (if configured)
```

### Testing
```bash
# All tests
bin/rails test

# Single test file
bin/rails test test/models/user_test.rb

# Single test method
bin/rails test test/models/user_test.rb --name=test_valid_presence

# Test with verbose output
bin/rails test -v

# System tests (requires display/Selenium)
bin/rails test:system
```

### Linting & Code Quality
```bash
# Ruby style checking (RuboCop)
bin/rubocop                    # All files
bin/rubocop app/models/user.rb  # Specific file
bin/rubocop --autocorrect      # Auto-fix issues

# Security audits
bin/bundler-audit              # Check gems for vulnerabilities
bin/importmap audit            # Check importmap for vulnerabilities
bin/brakeman                   # Static security analysis

# Full CI pipeline (mirrors GitHub Actions)
bin/ci
```

### Database
```bash
bin/rails db:create           # Create database
bin/rails db:migrate           # Run migrations
bin/rails db:seed              # Seed database
bin/rails db:seed:replant      # Reset and reseed
bin/rails db:rollback          # Rollback last migration
```

### Code Generators
```bash
bin/rails generate scaffold Product name:string price:decimal   # Full scaffold
bin/rails generate model Product name:string price:decimal      # Model only
bin/rails generate controller Products index show               # Controller only
bin/rails generate migration AddQuantityToProducts quantity:integer
```

## Code Style Guidelines

### General Philosophy
- Follow Rails conventions (convention over configuration)
- Use RuboCop with `rubocop-rails-omakase` preset (inherits from `rubocop-rails-omakase` gem)
- Write clear, readable code; prefer explicitness over cleverness

### Ruby Style
- **2-space indentation** (soft tabs)
- **Single quotes** for strings without interpolation: `'hello'`
- **Double quotes** for strings with interpolation: `"hello #{name}"`
- **No trailing commas** in multi-line lists/hashes
- **Line length**: ~100 characters max (RuboCop default)
- **Empty lines**: Single blank line between method definitions; no blank lines within methods

### Naming Conventions
- **Classes/Modules**: `PascalCase` (e.g., `ApplicationController`)
- **Methods/variables**: `snake_case` (e.g., `user_params`, `find_user`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Files**: `snake_case.rb` matching class name (e.g., `app/models/user.rb` -> `User` class)
- **Database columns**: `snake_case` (e.g., `created_at`, `user_id`)
- **Routes**: Use plural resource routing (`resources :users`)

### Method Definitions
```ruby
# Good
def index
  @users = User.all
end

def create
  @user = User.new(user_params)
  if @user.save
    redirect_to @user, notice: "Created successfully"
  else
    render :new, status: :unprocessable_entity
  end
end

# Private methods at bottom with _params suffix
private

def user_params
  params.require(:user).permit(:name, :email)
end
```

### Conditionals
```ruby
# Prefer early returns
def show
  @user = User.find(params[:id])
  return redirect_to(users_path) unless @user
  render
end

# Ternary for simple assignments
role = user.admin? ? "Administrator" : "User"

# Avoid assignment in conditionals (unless intentional)
if (user = User.find(params[:id]))
  # ...
end
```

### ActiveRecord/Model Conventions
```ruby
class User < ApplicationRecord
  # Scopes first
  scope :active, -> { where(active: true) }

  # Constants second
  MAX_LOGIN_ATTEMPTS = 5

  # Associations
  belongs_to :organization
  has_many :orders

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :name, length: { minimum: 2, maximum: 100 }

  # Callbacks (avoid when possible; consider service objects)
  before_validation :normalize_name

  # Class methods
  def self.by_email(email)
    find_by(email: email)
  end
end
```

### Controllers
```ruby
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!

  def index
    @users = User.all
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "User created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    redirect_to users_path, notice: "User deleted"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
```

### Views
- Use Turbo Streams (`turbo_stream`) for AJAX responses
- Use `render @user` for partial rendering
- Avoid logic in views; push complexity to helpers/models
- Use `content_tag` for complex HTML, plain HTML for simple cases

### Testing Conventions
```ruby
# Use descriptive test names
test "valid user with email and password is saved" do
  user = User.new(email: "test@example.com", password: "password")
  assert user.save
end

# Minitest style (default Rails)
assert_difference "User.count", 1 do
  post users_url, params: { user: { name: "Test" } }
end

# Use fixtures for test data (in test/fixtures/*.yml)
# Use assert_redirected_to, assert_template, assert_response
```

### Error Handling
- Use `find_by!` (with bang) when record must exist, handle 404 otherwise
- Use `save!`/`update!` when you want exceptions on failure
- Use `save`/`update` with conditional checks when handling validation errors
- Return proper HTTP status codes (200, 201, 400, 404, 422, 500)

### Dependencies
- **Gems in :test and :development groups**: Include in those groups only
- **Gemfile ordering**: Rails gems → database → JavaScript → background jobs → caching → deployment → development/test tools
- Avoid adding gems without clear justification; prefer standard library when possible

### Security
- Strong parameters for all user input
- No sensitive data in logs (passwords, tokens)
- Use environment variables for secrets (credentials.yml.enc for Rails secrets)
- Sanitize HTML when displaying user-generated content

### Performance
- Use `includes`/`preload` to avoid N+1 queries
- Use `pluck` when only specific columns needed
- Use `counter_cache` for frequent counts
- Add database indexes for frequently queried columns
