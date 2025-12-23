#!/bin/bash
# ==============================================================================
# Quality Tracker - Backend Deployment Script
# ==============================================================================
# Usage: ./deploy-backend.sh [branch-name]
# Example: ./deploy-backend.sh feature/new-api
# If no branch provided, uses current branch
#
# Environment Variables:
#   REPO_URL - Repository URL (default: https://github.com/mohammed-ibenayad/asaltech-quality-tracker.git)
#
# If the backend directory doesn't exist, it will be automatically cloned.
# ==============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="${REPO_URL:-https://github.com/mohammed-ibenayad/asaltech-quality-tracker.git}"
BACKEND_DIR="$HOME/quality-tracker-backend"
LOG_FILE="$HOME/deploy-backend-$(date +%Y%m%d_%H%M%S).log"
PM2_ECOSYSTEM="$BACKEND_DIR/packages/backend/ecosystem.config.js"

# Functions
log() {
    echo -e "${2}$1${NC}" | tee -a "$LOG_FILE"
}

section() {
    echo "" | tee -a "$LOG_FILE"
    echo "============================================================" | tee -a "$LOG_FILE"
    log "$1" "$CYAN"
    echo "============================================================" | tee -a "$LOG_FILE"
}

error_exit() {
    log "❌ ERROR: $1" "$RED"
    exit 1
}

success() {
    log "✅ $1" "$GREEN"
}

warning() {
    log "⚠️  $1" "$YELLOW"
}

info() {
    log "ℹ️  $1" "$BLUE"
}

# ==============================================================================
# STEP 0: INITIALIZATION
# ==============================================================================
section "STEP 0: Initialization"

# Check if directory exists, clone if not
if [ ! -d "$BACKEND_DIR" ]; then
    warning "Backend directory not found: $BACKEND_DIR"
    info "Cloning repository from: $REPO_URL"

    git clone "$REPO_URL" "$BACKEND_DIR" || error_exit "Failed to clone repository"
    success "Repository cloned successfully"
fi

cd "$BACKEND_DIR" || error_exit "Cannot change to backend directory"

# Verify this is the monorepo by checking for packages directory
if [ ! -d "packages/backend" ]; then
    error_exit "Cannot find packages/backend directory - is this the quality tracker monorepo?"
fi

# Determine branch to deploy
DEPLOY_BRANCH="${1:-$(git branch --show-current)}"
info "Target directory: $BACKEND_DIR"
info "Backend package: packages/backend"
info "Deploy branch: $DEPLOY_BRANCH"
info "Log file: $LOG_FILE"

# ==============================================================================
# STEP 1: GIT STATUS CHECK (INFORMATIONAL ONLY)
# ==============================================================================
section "STEP 1: Checking Git Status"

info "Current branch: $(git branch --show-current)"
info "Last local commit: $(git log -1 --oneline)"

# Show uncommitted changes if any (but don't block deployment)
if ! git diff-index --quiet HEAD --; then
    warning "Local uncommitted changes detected (will be discarded):"
    git status --short
    info "These changes will be overwritten by force pull"
else
    success "Working directory is clean"
fi

# ==============================================================================
# STEP 2: FORCE PULL LATEST CHANGES
# ==============================================================================
section "STEP 2: Force Pulling Latest Changes"

info "Fetching latest changes from remote..."
git fetch origin || error_exit "Failed to fetch from remote"

info "Force checking out branch: $DEPLOY_BRANCH"
git checkout -f "$DEPLOY_BRANCH" || error_exit "Failed to checkout branch $DEPLOY_BRANCH"

info "Resetting to origin/$DEPLOY_BRANCH (discarding local changes)..."
git reset --hard "origin/$DEPLOY_BRANCH" || error_exit "Failed to reset to remote branch"

# Clean untracked files except .env and node_modules
info "Cleaning untracked files (keeping .env)..."
git clean -fd -e .env -e node_modules || warning "Clean failed (continuing anyway)"

success "Code updated successfully (forced)"
info "Current commit: $(git log -1 --oneline)"

# ==============================================================================
# STEP 3: INSTALL DEPENDENCIES
# ==============================================================================
section "STEP 3: Installing Dependencies"

info "Running npm install..."
npm install || error_exit "npm install failed"

success "Dependencies installed"

# ==============================================================================
# STEP 3.5: ENVIRONMENT CONFIGURATION
# ==============================================================================
section "STEP 3.5: Environment Configuration"

# Check for .env file in backend package
if [ ! -f "packages/backend/.env" ]; then
    warning ".env file not found in packages/backend"

    if [ -f "packages/backend/.env.example" ]; then
        info "Creating .env from .env.example..."
        cp packages/backend/.env.example packages/backend/.env
        success ".env file created from template"
        warning "Please edit ~/quality-tracker-backend/packages/backend/.env with your actual configuration"
    else
        warning "No .env.example found - you may need to create .env manually"
    fi
else
    success ".env file exists"
fi

# ==============================================================================
# STEP 4: DATABASE MIGRATION (if needed)
# ==============================================================================
section "STEP 4: Database Check"

info "Testing database connection..."
if [ -f "packages/backend/database/test-connection.js" ]; then
    if node packages/backend/database/test-connection.js 2>&1 | grep -q "ready for use"; then
        success "Database connection verified"
    else
        warning "Database connection test failed (continuing anyway)"
    fi
else
    warning "Database test script not found (skipping)"
fi

# ==============================================================================
# STEP 5: STOP CURRENT SERVICES
# ==============================================================================
section "STEP 5: Stopping Current Services"

info "Checking PM2 status..."
pm2 status

info "Stopping quality-tracker services..."
pm2 stop quality-tracker-webhook 2>/dev/null || warning "Webhook service not running"
pm2 stop quality-tracker-api 2>/dev/null || warning "API service not running"

# Wait for services to stop
sleep 2
success "Services stopped"

# ==============================================================================
# STEP 6: START SERVICES
# ==============================================================================
section "STEP 6: Starting Services"

info "Starting services with PM2..."
if [ -f "$PM2_ECOSYSTEM" ]; then
    # PM2 needs to be started from the backend package directory
    cd packages/backend || error_exit "Cannot change to packages/backend"
    pm2 start ecosystem.config.js || error_exit "Failed to start services"
    cd ../.. || error_exit "Cannot return to root directory"
    success "Services started from ecosystem.config.js"
else
    warning "ecosystem.config.js not found, starting manually..."
    cd packages/backend || error_exit "Cannot change to packages/backend"
    pm2 start webhook-server.js --name quality-tracker-webhook
    pm2 start api-server.js --name quality-tracker-api
    cd ../.. || error_exit "Cannot return to root directory"
    success "Services started manually"
fi

# Save PM2 configuration
info "Saving PM2 configuration..."
pm2 save || warning "Failed to save PM2 config"

# Wait for services to start
sleep 3

# ==============================================================================
# STEP 7: VERIFY SERVICES
# ==============================================================================
section "STEP 7: Verifying Services"

# Check PM2 status
info "Current PM2 status:"
pm2 status

# Check if services are actually running (not crash-looping)
# Use pm2 jlist to get JSON output and parse it properly
WEBHOOK_STATUS=$(pm2 jlist | jq -r '.[] | select(.name=="quality-tracker-webhook") | .pm2_env.status' 2>/dev/null || echo "unknown")
API_STATUS=$(pm2 jlist | jq -r '.[] | select(.name=="quality-tracker-api") | .pm2_env.status' 2>/dev/null || echo "unknown")

info "Webhook service status: $WEBHOOK_STATUS"
info "API service status: $API_STATUS"

if [ "$WEBHOOK_STATUS" != "online" ]; then
    warning "Webhook service is not online (status: $WEBHOOK_STATUS)"
    info "Showing last 30 lines of webhook server logs:"
    pm2 logs quality-tracker-webhook --lines 30 --nostream || true
    error_exit "Webhook server is not running properly. Check logs above."
fi

if [ "$API_STATUS" != "online" ]; then
    warning "API service is not online (status: $API_STATUS)"
    info "Showing last 30 lines of API server logs:"
    pm2 logs quality-tracker-api --lines 30 --nostream || true
    error_exit "API server is not running properly. Check logs above."
fi

# Test webhook server
info "Testing webhook server (port 3001)..."
WEBHOOK_RESPONSE=$(curl -s http://localhost:3001/api/webhook/health 2>/dev/null || echo "failed")
if [[ "$WEBHOOK_RESPONSE" == *"healthy"* ]]; then
    success "Webhook server responding"
else
    warning "Health check failed, showing webhook server logs:"
    pm2 logs quality-tracker-webhook --lines 30 --nostream || true
    error_exit "Webhook server health check failed"
fi

# Test API server
info "Testing API server (port 3002)..."
API_RESPONSE=$(curl -s http://localhost:3002/api/health 2>/dev/null || echo "failed")
if [[ "$API_RESPONSE" == *"healthy"* ]]; then
    success "API server responding"
else
    error_exit "API server health check failed"
fi

# ==============================================================================
# STEP 8: RELOAD NGINX
# ==============================================================================
section "STEP 8: Reloading Nginx"

info "Testing nginx configuration..."
if sudo nginx -t; then
    success "Nginx configuration valid"
    
    info "Reloading nginx..."
    sudo systemctl reload nginx || warning "Failed to reload nginx"
    success "Nginx reloaded"
else
    warning "Nginx configuration test failed (continuing anyway)"
fi

# ==============================================================================
# STEP 9: SUMMARY
# ==============================================================================
section "DEPLOYMENT COMPLETE"

echo ""
success "Backend deployed successfully!"
echo ""
info "Branch: $DEPLOY_BRANCH"
info "Commit: $(git log -1 --oneline)"
info "Deployed to: $BACKEND_DIR/packages/backend"
echo ""
log "📊 Service Status:" "$GREEN"
pm2 status | grep quality-tracker
echo ""
log "🌐 Access your services at:" "$GREEN"
echo "   API Health: http://213.6.2.229/api/health"
echo "   Webhook Health: http://213.6.2.229/health"
echo ""
info "Log saved to: $LOG_FILE"
echo ""
log "📝 Useful commands:" "$BLUE"
echo "   View logs: pm2 logs"
echo "   Monitor: pm2 monit"
echo "   Restart: pm2 restart ecosystem.config.js"
echo ""

echo ""
log "🎉 All done! Happy testing!" "$CYAN"
echo ""