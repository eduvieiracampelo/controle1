# AGENTS.md - Coding Guidelines for Controle

Rails 8.1 application with SQLite, Turbo, Stimulus, Kamal deployment, and Solid Cache/Queue/Cable.

## Build/Lint/Test Commands

### Development
```bash
bin/rails server          # Start development server
bin/setup                 # Install dependencies and prepare database
bin/dev                   # Start development server with foreman (if configured)
```

### Testing
```bash
bin/rails test                                    # All tests
bin/rails test test/models/transaction_test.rb   # Single test file
bin/rails test test/models/transaction_test.rb --name=test_valid_presence  # Single test
bin/rails test -v                                 # Verbose output
bin/rails test:system                             # System tests (requires display)
```

### Linting & Code Quality
```bash
bin/rubocop                    # Ruby style (RuboCop with rails-omakase preset)
bin/rubocop app/models/user.rb  # Specific file
bin/rubocop --autocorrect      # Auto-fix issues
bin/bundler-audit              # Gem vulnerability audit
bin/importmap audit            # Importmap vulnerability audit
bin/brakeman                   # Static security analysis
bin/ci                         # Full CI pipeline
```

### Database
```bash
bin/rails db:create          # Create database
bin/rails db:migrate          # Run migrations
bin/rails db:seed             # Seed database
bin/rails db:seed:replant     # Reset and reseed
bin/rails db:rollback         # Rollback last migration
```

## Code Style

### Formatting
- **2-space indentation**, soft tabs
- **Single quotes** without interpolation; **double quotes** with interpolation
- **No trailing commas** in multi-line lists/hashes
- **Line length**: ~100 characters max
- Single blank line between method definitions; none within methods

### Naming Conventions
- **Classes/Modules**: `PascalCase`
- **Methods/variables**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Files**: `snake_case.rb` matching class name
- **Database columns**: `snake_case` (e.g., `created_at`, `user_id`)
- **Routes**: Plural resource routing (`resources :users`)

### Model Conventions
```ruby
class Transaction < ApplicationRecord
  # Scopes first, then constants, associations, validations, callbacks
  scope :by_date, -> { order(date: :desc) }
  scope :by_account, ->(id) { where(account_id: id) if id.present? }
  
  belongs_to :account
  has_many :transaction_tags, dependent: :destroy
  
  enum :transaction_type, { expense: 0, income: 1 }, prefix: true
  
  validates :amount, presence: true, numericality: { not_equal_to: 0 }
  
  before_validation :set_default_values
  
  # Class methods
  def self.by_period(start, end_date)
    where(date: start..end_date)
  end
end
```

### Controller Conventions
```ruby
class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :load_collections, only: [:index, :new, :edit]
  
  def index
    @transactions = Transaction.by_date
    @transactions = @transactions.by_account(params[:account_id]) if params[:account_id].present?
  end
  
  def show; end  # Implicit render for single-line actions
  
  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      redirect_to @transaction, notice: "Created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_transaction
    @transaction = Transaction.find(params[:id])
  end
  
  def transaction_params
    params.require(:transaction).permit(:amount, :description, :date, tag_ids: [])
  end
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

# Avoid assignment in conditionals
```

### Error Handling
- Use `find_by!` when record must exist (raises ActiveRecord::RecordNotFound)
- Use `save!`/`update!`/`destroy!` for destructive operations
- Return proper HTTP status codes: 200, 201, 400, 404, 422, 500

### Views
- Use Turbo Streams (`turbo_stream`) for AJAX responses
- Use `render @object` for partial rendering
- Avoid logic in views; push to helpers/models

### Testing Conventions
```ruby
class TransactionTest < ActiveSupport::TestCase
  test "valid transaction with amount and date is saved" do
    transaction = Transaction.new(amount: 100, date: Date.current)
    assert transaction.save
  end
  
  # Use assert_difference for creation/destruction tests
  assert_difference("Tag.count", 1) do
    post tags_url, params: { tag: { name: "Test" } }
  end
end

# Fixtures in test/fixtures/*.yml
# Use assert_redirected_to, assert_template, assert_response
```

### Security
- Strong parameters for all user input (`params.require().permit()`)
- No sensitive data in logs (passwords, tokens)
- Use environment variables for secrets

### Performance
- Use `includes`/`preload` to avoid N+1 queries
- Use `pluck` for specific columns
- Add database indexes for frequently queried columns
