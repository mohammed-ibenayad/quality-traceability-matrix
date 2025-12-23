# Deployment Setup Guide

This guide will help you set up the Quality Tracker application for deployment.

## Step 1: Start PostgreSQL

```bash
# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql  # Enable auto-start on boot

# Verify it's running
sudo systemctl status postgresql
```

## Step 2: Create Database and User

```bash
# Switch to postgres user
sudo -u postgres psql

# Inside psql, run these commands:
CREATE DATABASE quality_tracker_db;
CREATE USER quality_tracker_user WITH ENCRYPTED PASSWORD 'your_secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE quality_tracker_db TO quality_tracker_user;

# Grant schema permissions (PostgreSQL 15+)
\c quality_tracker_db
GRANT ALL ON SCHEMA public TO quality_tracker_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO quality_tracker_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO quality_tracker_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO quality_tracker_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO quality_tracker_user;

# Exit psql
\q
```

**Important:** Choose a strong password and remember it!

## Step 3: Initialize Database Schema

```bash
# From the project root
cd ~/projects/asaltech-quality-tracker

# Run the database initialization script
node packages/backend/database/init/run-init.js
```

## Step 4: Create Backend .env File

Create the `.env` file in the deployment directory:

```bash
# Create .env file in your local project first (for reference)
nano packages/backend/.env
```

Add this configuration:

```env
NODE_ENV=production
PORT=3001
HOST=0.0.0.0
FRONTEND_URL=http://213.6.2.229
FRONTEND_URL_ALT=http://localhost:5173
INTERNAL_IP=http://localhost
LOG_LEVEL=info
MAX_PAYLOAD_SIZE=10mb
RESULT_TTL=3600000
CLEANUP_INTERVAL=1800000
MAX_PROCESSED_WEBHOOKS=1000

# ============================================
# DATABASE CONFIGURATION
# ============================================
DB_HOST=localhost
DB_PORT=5432
DB_NAME=quality_tracker_db
DB_USER=quality_tracker_user
DB_PASSWORD=your_secure_password_here

# Connection Pool Settings
DB_POOL_MIN=2
DB_POOL_MAX=10

# Feature Flags
ENABLE_DATABASE=true
USE_DATABASE_READ=false
USE_DATABASE_WRITE=true

# API Server Configuration
API_PORT=3002
```

**Important:** Replace `your_secure_password_here` with the actual password you set in Step 2.

## Step 5: Create Frontend .env File (Optional)

If you need custom frontend configuration:

```bash
nano packages/frontend/.env
```

Add:

```env
VITE_API_URL=http://213.6.2.229/api
REACT_APP_WEBHOOK_URL=http://213.6.2.229
REACT_APP_BACKEND_ENABLED=true
```

## Step 6: Test Database Connection

```bash
# Test the connection
node packages/backend/database/test-connection.js
```

You should see: `✅ Database connection successful and ready for use`

## Step 7: Deploy Backend

Now run the deploy script:

```bash
./scripts/deploy-backend.sh
```

The script will:
- Clone to `~/quality-tracker-backend`
- Auto-create `.env` from your template
- Install dependencies
- Start PM2 services
- Verify health checks

## Step 8: Configure .env in Deployment Directory

After first deployment, you need to update the `.env` in the deployment location:

```bash
# Copy your configured .env to the deployment directory
cp packages/backend/.env ~/quality-tracker-backend/packages/backend/.env

# Or edit it directly
nano ~/quality-tracker-backend/packages/backend/.env
```

Make sure to set the correct database password!

## Step 9: Restart Services

After updating `.env`:

```bash
cd ~/quality-tracker-backend/packages/backend
pm2 restart ecosystem.config.js
pm2 save
```

## Step 10: Verify Everything Works

```bash
# Check PM2 status
pm2 status

# Check logs
pm2 logs quality-tracker-webhook --lines 20
pm2 logs quality-tracker-api --lines 20

# Test health endpoints
curl http://localhost:3001/api/webhook/health
curl http://localhost:3002/api/health
```

## Quick Reference

### Database Commands

```bash
# Connect to database
sudo -u postgres psql -d quality_tracker_db

# List tables
\dt

# Check users
\du

# Reset password if forgotten
sudo -u postgres psql -c "ALTER USER quality_tracker_user WITH PASSWORD 'new_password';"
```

### PM2 Commands

```bash
pm2 status                          # View all processes
pm2 logs                           # View all logs
pm2 logs quality-tracker-webhook   # View webhook logs
pm2 logs quality-tracker-api       # View API logs
pm2 restart all                    # Restart all services
pm2 stop all                       # Stop all services
pm2 save                           # Save current configuration
```

### Troubleshooting

**Services keep restarting:**
- Check PM2 logs: `pm2 logs`
- Usually means missing .env or wrong database credentials

**Database connection failed:**
- Check PostgreSQL is running: `sudo systemctl status postgresql`
- Verify credentials in .env match database user
- Test connection: `node packages/backend/database/test-connection.js`

**Port already in use:**
- Find process: `sudo lsof -i :3001` or `sudo lsof -i :3002`
- Stop PM2: `pm2 stop all`
- Kill process: `sudo kill -9 <PID>`

## Security Notes

1. **Never commit .env files** - They contain sensitive passwords
2. **Use strong database passwords** - At least 16 characters
3. **Restrict database access** - Only allow localhost connections for production
4. **Keep .env files private** - Set permissions: `chmod 600 packages/backend/.env`

## Next Steps

After successful deployment:
1. Deploy frontend: `./scripts/deploy-frontend.sh`
2. Configure Nginx (if not already done)
3. Set up SSL certificates
4. Configure automatic backups for the database
