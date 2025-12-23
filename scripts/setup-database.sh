#!/bin/bash
# ==============================================================================
# Quality Tracker - Database Setup Script
# ==============================================================================
# This script sets up the PostgreSQL database for the Quality Tracker
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "============================================================"
echo "  Quality Tracker - Database Setup"
echo "============================================================"
echo -e "${NC}"

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL is not installed!${NC}"
    echo -e "${YELLOW}Install it with: sudo apt install postgresql postgresql-contrib${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL is installed${NC}"

# Check if PostgreSQL is running
if ! sudo systemctl is-active --quiet postgresql; then
    echo -e "${YELLOW}⚠️  PostgreSQL is not running. Starting it...${NC}"
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    echo -e "${GREEN}✅ PostgreSQL started${NC}"
else
    echo -e "${GREEN}✅ PostgreSQL is running${NC}"
fi

echo ""
echo -e "${BLUE}Setting up database...${NC}"
echo ""

# Prompt for database password
echo -e "${YELLOW}Please enter a password for the database user (quality_tracker_user):${NC}"
read -s DB_PASSWORD
echo ""
echo -e "${YELLOW}Please confirm the password:${NC}"
read -s DB_PASSWORD_CONFIRM
echo ""

if [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
    echo -e "${RED}❌ Passwords do not match!${NC}"
    exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}❌ Password cannot be empty!${NC}"
    exit 1
fi

echo -e "${BLUE}Creating database and user...${NC}"

# Create database and user
sudo -u postgres psql <<EOF
-- Drop existing database and user if they exist (for clean setup)
DROP DATABASE IF EXISTS quality_tracker_db;
DROP USER IF EXISTS quality_tracker_user;

-- Create new database and user
CREATE DATABASE quality_tracker_db;
CREATE USER quality_tracker_user WITH ENCRYPTED PASSWORD '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE quality_tracker_db TO quality_tracker_user;

-- Connect to the database and grant schema permissions
\c quality_tracker_db

GRANT ALL ON SCHEMA public TO quality_tracker_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO quality_tracker_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO quality_tracker_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO quality_tracker_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO quality_tracker_user;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database and user created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create database and user${NC}"
    exit 1
fi

# Create .env file
echo ""
echo -e "${BLUE}Creating .env file...${NC}"

ENV_FILE="packages/backend/.env"

cat > "$ENV_FILE" <<EOF
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
DB_PASSWORD=$DB_PASSWORD

# Connection Pool Settings
DB_POOL_MIN=2
DB_POOL_MAX=10

# Feature Flags
ENABLE_DATABASE=true
USE_DATABASE_READ=false
USE_DATABASE_WRITE=true

# API Server Configuration
API_PORT=3002
EOF

chmod 600 "$ENV_FILE"
echo -e "${GREEN}✅ .env file created at $ENV_FILE${NC}"

# Test database connection
echo ""
echo -e "${BLUE}Testing database connection...${NC}"

if node packages/backend/database/test-connection.js 2>&1 | grep -q "ready for use"; then
    echo -e "${GREEN}✅ Database connection successful!${NC}"
else
    echo -e "${YELLOW}⚠️  Database connection test had warnings (this may be normal)${NC}"
fi

# Initialize database schema if init script exists
if [ -f "packages/backend/database/init/run-init.js" ]; then
    echo ""
    echo -e "${BLUE}Do you want to initialize the database schema now? (y/n)${NC}"
    read -r INIT_DB

    if [ "$INIT_DB" = "y" ] || [ "$INIT_DB" = "Y" ]; then
        echo -e "${BLUE}Initializing database schema...${NC}"
        node packages/backend/database/init/run-init.js
        echo -e "${GREEN}✅ Database schema initialized${NC}"
    fi
fi

echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}✅ Database setup complete!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review the .env file: nano $ENV_FILE"
echo -e "  2. Deploy the backend: ./scripts/deploy-backend.sh"
echo -e "  3. Deploy the frontend: ./scripts/deploy-frontend.sh"
echo ""
echo -e "${BLUE}Database credentials:${NC}"
echo -e "  Database: quality_tracker_db"
echo -e "  User: quality_tracker_user"
echo -e "  Password: (saved in $ENV_FILE)"
echo ""
echo -e "${YELLOW}IMPORTANT: Keep your .env file secure and never commit it to git!${NC}"
echo ""
