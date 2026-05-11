# Database Setup & Configuration

## Overview

DTM Uses PostgreSQL with environment-based connection URLs. This approach allows the same Rails application to connect to different databases based on the deployment environment.

## Current Setup

### Staging Environment
- **Server**: Digital Ocean Droplet (178.128.199.154)
- **Database**: 'darts_tournament_staging' (PostgreSQL)
- **Connection**: TCP/IP via Docker network
- **Rails Environment**: `production` (with staging DATABASE_URL)
---
### Multi-Database Configuration
DTM uses Rails 8's multi-database setup with fallback URLs:
```yaml
production:
  primary:
    url: <%= ENV["DATABASE_URL"] %>
  cache:
    url: <%= ENV["CACHE_DATABASE_URL"] || ENV["DATABASE_URL"] %>
  queue:
    url: <%= ENV["QUEUE_DATABASE_URL"] || ENV["DATABASE_URL"] %>
  cable:
    url: <%= ENV["CABLE_DATABASE_URL"] || ENV["DATABASE_URL"] %>
```

#### Staging Setup (Current)
All databases fallback to DATABASE_URL pointing to darts_tournament_staging:
- Primary, Cache, Queue, and Cable tables coexist in one database
- Simpler management for staging/testing

####  Production Setup (Future)
  Create separate databases and set individual URLs:
- DATABASE_URL → darts_tournament_production
- CACHE_DATABASE_URL → darts_tournament_production_cache
- QUEUE_DATABASE_URL → darts_tournament_production_queue
- CABLE_DATABASE_URL → darts_tournament_production_cable
---
### Environment Variables
```
DATABASE_URL=postgres://darts_tournament:PASSWORD@178.128.199.154:5432/darts_tournament_staging
```
---
### PostgreSQL Server Configuration

#### Droplet Setup
```bash
# 1. Install PostgreSQL
apt install postgresql postgresql-contrib

# 2. Create user
sudo -u postgres psql -c "CREATE USER darts_tournament WITH PASSWORD 'PASSWORD';"

# 3. Create database
sudo -u postgres psql -c "CREATE DATABASE darts_tournament_staging OWNER darts_tournament;"

# 4. Configure pg_hba.conf to accept Docker connections
echo "host all all 172.17.0.0/16 md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
echo "host all all 172.18.0.0/16 md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf

# 5. Set listen addresses to '*' in postgresql.conf

# 6. Restart PostgreSQL
sudo systemctl restart postgresql
```

#### Firewall Rules
- UFW allows connections from Docker network to port 5432
```bash
# commands
ufw allow from 172.17.0.0/16 to any port 5432
ufw allow from 172.18.0.0/16 to any port 5432
ufw reload
```
---
### Deployment Configuration

#### Kamal deploy.yml

- SOLID_QUEUE_IN_PUMA: false (disabled due to startup issues)
- RUN_DB_PREPARE: false (prevents health check timeouts)
- Environment secrets stored in `.kamal/secrets.yml` (gitignored)

#### Running Migrations
Migrations run for all databases automatically:
```bash
# This migrates primary, cache, queue, and cable
ssh root@178.128.199.154 "docker exec \$(docker ps -q | grep darts-tournament-web | head -1) bin/rails db:migrate"
```
Or migrate specific databases:
```bash
bin/rails db:migrate:primary
bin/rails db:migrate:cache
bin/rails db:migrate:queue
bin/rails db:migrate:cable
```
#### Solid Queue Configuration
Solid Queue runs inside Puma via the solid_queue plugin:
- Enabled when SOLID_QUEUE_IN_PUMA=true (default)
- Puma config: plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]
- Database tables created via rails db:migrate (queue migrations)
---
### Future Production Setup

When adding a production environment:

#### New Server Setup
1. Create a new Digital Ocean Droplet
2. Install Docker and PostgreSQL
3. Create a production database: darts_tournament_production
4. Configure pg_hba.conf and firewall rules
5. Update Kamal config with new Server IP

#### Database Migration
1. Create `darts_tournament_production` database
2. Run migrations: `kamal app exec "bin/rails db:migrate"`
3. Production starts with empty database (no data migration from staging)

#### Environment Variables
Create separate `.kamal/secrets.yml` entry for production:

```yaml
production:
  DATABASE_URL: postgres://darts_tournament:PASSWORD@PROD_IP:5432/darts_tournament_production
```
---
### Troubleshooting

#### Connection via Unix Socket
If Rails tries to connect via socket instead of TCP/IP:
- Verify DATABASE_URL is set in container: `docker inspect <container> | grep DATABASE_URL`
- Ensure database.yml uses url: `<%= ENV["DATABASE_URL"] %>`

####  Migration Failures
  If migrations fail with connection errors:
- Check PostgreSQL is running: sudo systemctl status postgresql
- Verify pg_hba.conf allows Docker connections
- Check UFW isn't blocking port 5432
- Use docker exec method instead of kamal app exec