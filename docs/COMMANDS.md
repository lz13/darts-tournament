# Commands Reference
## Development
```bash
# Start development server (Rails + Tailwind watcher)
bin/dev

# Start Rails server only
bin/rails server

# Rails console
bin/rails console

# View all routes
bin/rails routes
```

## Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/tournament_spec.rb

# Run tests with documentation (verbose) format
bundle exec rspec --format documentation

# Run only failing tests
bundle exec rspec --only-failures
```

## Database
```bash
# Create databases
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Rollback last migration
bin/rails db:rollback

# Reset database (drop, create, migrate, seed)
bin/rails db:reset

# View migration status
bin/rails db:migrate:status
```

## Generators
```bash
# Generate a new model
bin/rails generate model ModelName field:type

# Generate a controller
bin/rails generate controller ControllerName action1 action2

# Generate a migration
bin/rails generate migration AddFieldToTable field:type

# Destroy (undo) a generator
bin/rails destroy model ModelName
```

## Assets
```bash
# Precompile assets
bin/rails assets:precompile

# Clean compiled assets
bin/rails assets:clobber
```

## Debugging
```bash
# Check Ruby version
ruby -v

# Check Rails version
bin/rails -v

# Check installed gems
bundle list

# Update gems
bundle update
```
---