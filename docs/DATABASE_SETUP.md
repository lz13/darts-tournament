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
### Connection Method
```yaml
# config/database.yml
production:
  primary:
    <<: *default
    url: <%= ENV['DATABASE_URL'] %>
```
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
Since `kamal app exec` has issues with DATABASE_URL, use docker exec:

```bash
ssh root@178.128.199.154
docker ps (to find container ID)
docker exec -it CONTAINER_ID bin/rails db:migrate (to run migrations)
```

#### Why Disabled
Solid Queue was causing Puma ot crash during startup because:
1. It tried to boot before database was accessible
2. Created a circular dependency (needs DB to boot, but DB needs App to be healthy)
3. The `SOLID_QUEUE_IN_PUMA=true` env var always evaluated to be truthy in Ruby

#### Fix Applied
- Modified `config/puma.rb` to checl `ENV["SOLID_QUEUE_IN_PUMA"] == "true"`
- Set `SOLID_QUEUE_IN_PUMA: false` in `deploy.yml`

#### Future Re-enable
When background jobs are needed:
1. Create Solid Queue database tables via migration
2. Run Solid Queue as a separate Kamal accessory / service
3. Or fix the root cause and re-enable in Puma
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