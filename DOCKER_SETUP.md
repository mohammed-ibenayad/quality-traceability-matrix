# Running the Quality Traceability Matrix with Docker

This guide will help you run the entire application stack using Docker containers.

## Prerequisites

- Docker Engine (v20.10 or higher)
- Docker Compose (v2.0 or higher)

Check your installation:
```bash
docker --version
docker compose version
```

## Project Structure

The Docker setup includes:
- **PostgreSQL Database** - Running on port 5432
- **Backend API** - Node.js/Express on ports 3001 (webhook) and 3002 (API)
- **Frontend** - React/Vite app served via Nginx on port 80 (production) or 5173 (development)

## Quick Start (Production Mode)

### 1. Navigate to the docker directory
```bash
cd docker
```

### 2. Verify the .env file exists
The `.env` file has been created from `.env.example` with default values:
```bash
cat .env
```

### 3. Start all services
```bash
docker compose up -d
```

This will:
- Pull necessary Docker images
- Build the frontend and backend containers
- Start PostgreSQL, backend, and frontend services
- Set up networking between containers

### 4. Check service status
```bash
docker compose ps
```

### 5. View logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f postgres
```

### 6. Access the application
- **Frontend**: http://localhost
- **API**: http://localhost:3002
- **Webhook Server**: http://localhost:3001
- **Database**: localhost:5432

## Development Mode

For development with hot-reload:

### 1. Start with development configuration
```bash
cd docker
docker compose -f docker-compose.yml -f docker-compose.dev.yml up
```

This enables:
- Hot-reload for both frontend and backend
- Debug logging
- Development database with test credentials
- Source code mounted as volumes

### 2. Access the development application
- **Frontend**: http://localhost:5173 (Vite dev server)
- **API**: http://localhost:3002
- **Webhook Server**: http://localhost:3001
- **Database**: localhost:5432

## Database Initialization

The PostgreSQL container automatically runs initialization scripts from:
```
packages/backend/database/init/
```

On first startup, the database will:
1. Create the schema
2. Set up tables and views
3. Run any seed data scripts

## Environment Variables

Key variables in `docker/.env`:

```env
# Database
DB_NAME=quality_tracker_db
DB_USER=quality_tracker_user
DB_PASSWORD=Bf@r!s2015
DB_PORT=5432

# Backend
NODE_ENV=production
PORT=3001          # Webhook server
API_PORT=3002      # API server
LOG_LEVEL=info

# Frontend
FRONTEND_PORT=80
```

## Common Commands

### Stop all services
```bash
docker compose down
```

### Stop and remove volumes (clean slate)
```bash
docker compose down -v
```

### Rebuild containers
```bash
docker compose build
docker compose up -d
```

### Rebuild specific service
```bash
docker compose build backend
docker compose up -d backend
```

### Execute commands in running containers
```bash
# Backend shell
docker compose exec backend sh

# Database shell
docker compose exec postgres psql -U quality_tracker_user -d quality_tracker_db

# View backend PM2 processes
docker compose exec backend pm2 status
```

### View resource usage
```bash
docker compose stats
```

## Troubleshooting

### Port conflicts
If ports 80, 5432, 3001, or 3002 are already in use:
1. Edit `docker/.env` to change port mappings
2. Restart services

### Database connection issues
```bash
# Check database health
docker compose exec postgres pg_isready -U quality_tracker_user

# Check database logs
docker compose logs postgres
```

### Container won't start
```bash
# Check logs
docker compose logs [service-name]

# Rebuild from scratch
docker compose down -v
docker compose build --no-cache
docker compose up
```

### Clear everything and start fresh
```bash
cd docker
docker compose down -v
docker system prune -f
docker compose build --no-cache
docker compose up -d
```

## Health Checks

All services include health checks:

- **PostgreSQL**: Checks `pg_isready`
- **Backend**: Checks `/api/health` endpoint
- **Frontend**: Checks Nginx availability

View health status:
```bash
docker compose ps
```

## Production Deployment

For production deployment:

1. Update `docker/.env` with production values
2. Set secure `DB_PASSWORD`
3. Configure `FRONTEND_URL` for CORS
4. Use production-grade secrets management
5. Set up reverse proxy (nginx/traefik) for SSL
6. Configure backup strategy for PostgreSQL data volume

## Network Architecture

All services communicate via the `quality-tracker-network` bridge network:

```
Frontend (Nginx) → Backend API (3002)
Frontend (Nginx) → Webhook Server (3001)
Backend → PostgreSQL (5432)
```

The frontend Nginx configuration automatically proxies:
- `/api/*` requests to backend:3002
- `/socket.io/*` requests to backend:3001

## Data Persistence

PostgreSQL data is persisted in a Docker volume:
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect docker_postgres_data
```

## Next Steps

1. **Access the application**: Navigate to http://localhost
2. **Check logs**: Monitor `docker compose logs -f` for any issues
3. **Test the API**: Visit http://localhost:3002/api/health
4. **Load test data**: Use the backend seed scripts if available

## Support

For issues or questions:
- Check logs: `docker compose logs -f`
- Review environment variables in `docker/.env`
- Ensure all required ports are available
- Verify Docker and Docker Compose versions meet requirements
