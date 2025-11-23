# Quick Start Guide

## 1. Start Docker Containers

```bash
cd docker
docker compose up -d
```

## 2. Seed the Database (First Time Only)

Create the default admin user:

```bash
docker compose exec backend npm run db:seed
```

This creates:
- **Email**: `admin@qualitytracker.local`
- **Password**: `admin123`
- **Default Workspace**: Default Workspace

## 3. Access the Application

Open your browser and navigate to:
```
http://localhost
```

Login with:
- **Email**: admin@qualitytracker.local
- **Password**: admin123

## That's It! 🎉

Your Quality Traceability Matrix is now running and ready to use.

---

## Additional Commands

### View Logs
```bash
docker compose logs -f
```

### Stop Services
```bash
docker compose down
```

### Restart Services
```bash
docker compose restart
```

### Reset Database (Clean Slate)
```bash
docker compose down -v
docker compose up -d
docker compose exec backend npm run db:seed
```

### Check Service Status
```bash
docker compose ps
```

### Access Database Directly
```bash
docker compose exec postgres psql -U quality_tracker_user -d quality_tracker_db
```

## Troubleshooting

If you can't login after seeding, check the backend logs:
```bash
docker compose logs backend | grep -i "login\|seed\|user"
```

For more detailed documentation:
- **Docker Setup**: See `DOCKER_SETUP.md`
- **Verification Steps**: See `VERIFY_SETUP.md`
- **Fix Database Issues**: See `DOCKER_FIX.md`

## API Endpoints

- **Frontend**: http://localhost
- **API Health**: http://localhost:3002/api/health
- **Webhook Health**: http://localhost:3001/api/webhook/health
- **API Server**: http://localhost:3002/api
- **Webhook Server**: http://localhost:3001/api/webhook

## Default Credentials

Remember to change the default password after first login!

- Email: admin@qualitytracker.local
- Password: admin123

## Next Steps

1. Login to the application
2. Change the default password
3. Explore the Quality Traceability Matrix features
4. Configure your test webhooks
5. Start tracking your quality metrics!
