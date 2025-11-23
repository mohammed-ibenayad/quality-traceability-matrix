# Fixing Database Authentication Issue

## Problem
The PostgreSQL database has existing data from a previous initialization with different credentials. The current .env file specifies:
- User: `quality_tracker_user`
- Password: `Bf@r!s2015`

But the existing database doesn't have this user.

## Solution: Reset Database Volume

### Step 1: Stop all containers
```bash
cd docker
docker compose down
```

### Step 2: Remove the database volume
```bash
docker volume rm docker_postgres_data
```

Or if that doesn't work:
```bash
docker compose down -v
```

This removes all volumes including the PostgreSQL data.

### Step 3: Start containers fresh
```bash
docker compose up -d
```

The database will now initialize properly with the correct user and credentials.

### Step 4: Verify everything is working
```bash
# Check all containers are running
docker compose ps

# Check logs
docker compose logs -f

# Test database connection
docker compose exec postgres psql -U quality_tracker_user -d quality_tracker_db -c "SELECT version();"
```

## Alternative: Use Development Credentials

If you want to keep the existing database, you can update `docker/.env` to match the existing database credentials.

Check what user exists:
```bash
docker compose exec postgres psql -U postgres -c "\du"
```

Then update `docker/.env` accordingly.

## Commands to Run Now

```bash
cd ~/mytools/quality-traceability-matrix/docker

# Stop containers
docker compose down

# Remove old database volume
docker compose down -v

# Start fresh
docker compose up -d

# Watch logs
docker compose logs -f
```

You should see the database initialize successfully and both backend servers connect without errors.
