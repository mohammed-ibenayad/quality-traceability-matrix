# Verify Docker Setup

## Quick Verification Commands

Run these commands to verify your setup is working correctly:

### 1. Check container health status
```bash
cd ~/mytools/quality-traceability-matrix/docker
docker compose ps
```

Expected output: All services should show "healthy" or "running" status.

### 2. Test API Health Endpoint
```bash
curl http://localhost:3002/api/health
```

Expected: Should return a 200 OK response with health status.

### 3. Test Webhook Health Endpoint
```bash
curl http://localhost:3001/api/webhook/health
```

### 4. Test Frontend
Open your browser and navigate to:
```
http://localhost
```

You should see the Quality Traceability Matrix frontend.

### 5. Test Database Connection Directly
```bash
docker compose exec postgres psql -U quality_tracker_user -d quality_tracker_db -c "SELECT COUNT(*) FROM schema_versions;"
```

This should return a count of schema version records.

### 6. View Detailed Backend Logs
```bash
docker compose logs backend | grep "✅"
```

You should see: `✅ Database connection established`

## Access Points

Once verified, you can access:

- **Frontend**: http://localhost
- **API Server**: http://localhost:3002
  - Health: http://localhost:3002/api/health
  - Swagger/API Docs: http://localhost:3002/api-docs (if configured)
- **Webhook Server**: http://localhost:3001
  - Health: http://localhost:3001/api/webhook/health
  - Test Results Endpoint: http://localhost:3001/api/webhook/test-results
- **Database**: localhost:5432
  - Database: quality_tracker_db
  - User: quality_tracker_user
  - Password: Bf@r!s2015

## Database Connection String

For external tools (DBeaver, pgAdmin, etc.):
```
postgresql://quality_tracker_user:Bf@r!s2015@localhost:5432/quality_tracker_db
```

## Troubleshooting

### If you see "FATAL: database quality_tracker_user does not exist"
This is normal! It's just PostgreSQL's health check trying to connect with a default database name. As long as you see `✅ Database connection established` in the backend logs, everything is working correctly.

### Check PM2 Process Status
```bash
docker compose exec backend pm2 status
```

Should show both processes running:
- quality-tracker-webhook
- quality-tracker-api

### View Real-time Logs
```bash
# All services
docker compose logs -f

# Just backend
docker compose logs -f backend

# Just database
docker compose logs -f postgres

# Just frontend
docker compose logs -f frontend
```

## Success Indicators

✅ Database schema created (19 tables, 3 views)
✅ Backend shows "Database connection established"
✅ Both webhook (3001) and API (3002) servers running
✅ Frontend Nginx started successfully
✅ All containers in "running" state

## Next Steps

1. Access http://localhost in your browser
2. Test the API endpoints
3. Start using the Quality Traceability Matrix!

If you need to stop the services:
```bash
docker compose down
```

To restart:
```bash
docker compose up -d
```
