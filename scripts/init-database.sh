#!/bin/bash
# ==============================================================================
# Quality Tracker - Quick Database Initialization
# ==============================================================================
# This script quickly initializes the database schema and seeds initial data
# It assumes PostgreSQL database and user already exist (created by setup-database.sh)
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "============================================================"
echo "  Quality Tracker - Database Initialization"
echo "============================================================"
echo -e "${NC}"

# Check if we're in the right directory
if [ ! -f "packages/backend/database/init/run-init.js" ]; then
    echo -e "${RED}❌ Error: Must run from project root directory${NC}"
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    exit 1
fi

# Check if .env exists
if [ ! -f "packages/backend/.env" ]; then
    echo -e "${RED}❌ Error: packages/backend/.env not found${NC}"
    echo -e "${YELLOW}Please run ./scripts/setup-database.sh first${NC}"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    exit 1
fi

echo -e "${BLUE}This script will:${NC}"
echo -e "  1. Create all database tables and schemas"
echo -e "  2. Seed initial data (admin user + default workspace)"
echo -e ""
echo -e "${YELLOW}⚠️  WARNING: This will reset the database if tables already exist${NC}"
echo -e ""
echo -e "${YELLOW}Do you want to continue? (y/n)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${BLUE}Initialization cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Running database initialization...${NC}"
echo ""

# Run initialization script
node packages/backend/database/init/run-init.js

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database initialization completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Start the backend: cd ~/quality-tracker-backend && pm2 restart all"
    echo -e "  2. Access the application at: http://213.6.2.229"
    echo -e "  3. Login with: admin@qualitytracker.local / admin123"
    echo ""
else
    echo -e "${RED}❌ Database initialization failed${NC}"
    echo -e "${YELLOW}Check the error messages above for details${NC}"
    exit 1
fi
