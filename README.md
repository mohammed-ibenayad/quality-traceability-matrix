# Quality Tracker

A comprehensive application for tracking the relationship between requirements and test cases in software development projects. This tool helps teams maintain visibility into test coverage, automation status, and release readiness.

## 🎯 Features

- **Dashboard**: Overview of release quality metrics, health scores, and risk areas
- **Traceability Matrix**: Visual mapping between requirements and test cases
- **Test Depth Analysis**: Calculate required test coverage based on business impact, complexity, and other factors
- **Quality Gates**: Define and track quality criteria that must be met before release
- **Risk Assessment**: Automatically identify high-risk areas based on test coverage and failure rates
- **Real-time Updates**: Live test execution results via WebSocket
- **GitHub Integration**: Sync with GitHub issues and pull requests
- **Database Backend**: PostgreSQL for persistent data storage

## 🏗️ Monorepo Structure

This project uses a monorepo structure with npm workspaces to manage both frontend and backend applications.

```
asaltech-quality-tracker/
├── packages/
│   ├── frontend/           # React application (Vite + React 19)
│   │   ├── src/
│   │   │   ├── components/ # Reusable UI components
│   │   │   ├── pages/      # Page components
│   │   │   ├── hooks/      # Custom React hooks
│   │   │   └── api/        # API integration
│   │   └── dist/           # Build output
│   │
│   └── backend/            # Node.js/Express API servers
│       ├── api/            # API endpoints and controllers
│       ├── database/       # Database schema and seeds
│       ├── api-server.js   # API server (port 3002)
│       └── webhook-server.js # Webhook server (port 3001)
│
├── scripts/                # Deployment and utility scripts
│   ├── deploy-backend.sh   # Backend deployment script
│   ├── deploy-frontend.sh  # Frontend deployment script
│   └── setup-database.sh   # Database setup automation
│
├── docs/                   # Documentation
└── docker/                 # Docker configurations
```

## 📦 Technology Stack

### Frontend
- React 19 with Vite
- TailwindCSS 3
- React Router 7
- Recharts for visualization
- Socket.io Client for real-time updates
- Axios for HTTP requests

### Backend
- Node.js with Express
- PostgreSQL (19 tables)
- Socket.io for WebSockets
- JWT for authentication
- PM2 for process management

### DevOps
- Docker & Docker Compose
- Nginx for production
- npm Workspaces (monorepo)

## 🚀 Quick Start

### Prerequisites

- Node.js >= 16.0.0
- npm >= 8.0.0
- PostgreSQL >= 12
- PM2 (for production deployment)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/mohammed-ibenayad/asaltech-quality-tracker.git
   cd asaltech-quality-tracker
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up database (automated)**
   ```bash
   ./scripts/setup-database.sh
   ```
   This will:
   - Start PostgreSQL
   - Create database and user
   - Generate `.env` file with credentials
   - Test the connection

4. **Start development servers**
   ```bash
   npm run dev
   ```
   This starts:
   - Frontend at http://localhost:5173
   - Webhook Server at http://localhost:3001
   - API Server at http://localhost:3002

## 🚢 Production Deployment

### Automated Deployment (Recommended)

The project includes automated deployment scripts that handle everything:

1. **Deploy Backend**
   ```bash
   ./scripts/deploy-backend.sh [branch-name]
   ```
   This will:
   - Clone repository to `~/quality-tracker-backend`
   - Install dependencies
   - Auto-create `.env` if missing
   - Start services with PM2
   - Run health checks

2. **Deploy Frontend**
   ```bash
   ./scripts/deploy-frontend.sh [branch-name]
   ```
   This will:
   - Clone repository to `~/quality-tracker-frontend`
   - Install dependencies
   - Build production bundle
   - Deploy to `/var/www/html`
   - Reload Nginx

### Manual Deployment

See [DEPLOYMENT_SETUP.md](./DEPLOYMENT_SETUP.md) for detailed manual deployment instructions.

### Docker Deployment

```bash
# Production
cd docker
docker-compose up -d

# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

See [DOCKER_SETUP.md](./DOCKER_SETUP.md) for Docker configuration details.

## 📝 Available Scripts

### Development
| Command | Description |
|---------|-------------|
| `npm run dev` | Start both frontend and backend in dev mode |
| `npm run dev:frontend` | Start frontend dev server (port 5173) |
| `npm run dev:backend` | Start backend webhook server |
| `npm run dev:api` | Start backend API server |

### Production
| Command | Description |
|---------|-------------|
| `npm run build` | Build frontend for production |
| `npm run start:backend` | Start backend servers with PM2 |
| `./scripts/deploy-backend.sh` | Deploy backend to production |
| `./scripts/deploy-frontend.sh` | Deploy frontend to production |

### Database
| Command | Description |
|---------|-------------|
| `./scripts/setup-database.sh` | Automated database setup |
| `npm run db:test` | Test database connection |
| `npm run db:seed` | Seed database with sample data |

## 🔧 Configuration

### Environment Variables

The project uses `.env` files for configuration:

**Backend** (`packages/backend/.env`):
```env
NODE_ENV=production
PORT=3001              # Webhook server port
API_PORT=3002          # API server port
HOST=0.0.0.0

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=quality_tracker_db
DB_USER=quality_tracker_user
DB_PASSWORD=your_secure_password

# Frontend URLs (for CORS)
FRONTEND_URL=http://your-domain.com
```

**Frontend** (`packages/frontend/.env`):
```env
VITE_API_URL=http://your-domain.com/api
REACT_APP_WEBHOOK_URL=http://your-domain.com
REACT_APP_BACKEND_ENABLED=true
```

See `.env.example` files for all available options.

## 📊 Database Schema

PostgreSQL database with 19 tables:
- User management (users, workspaces, projects)
- Requirements tracking (requirements, versions)
- Test management (test_cases, test_suites, test_executions)
- Traceability (requirement_test_mapping)
- Quality metrics (quality_gates, risk_assessments)
- Releases (releases, release_requirements)
- Audit logs (webhook_logs, audit_logs)

## 📚 Documentation

- [DEPLOYMENT_SETUP.md](./DEPLOYMENT_SETUP.md) - Detailed deployment guide
- [DOCKER_SETUP.md](./DOCKER_SETUP.md) - Docker configuration
- [QUICK_START.md](./QUICK_START.md) - Quick start guide
- [docs/ABOUT-TDF.md](./docs/ABOUT-TDF.md) - Test Depth Factor explained

## 🔒 Security

- **Never commit `.env` files** - They contain sensitive passwords
- **Use strong database passwords** - At least 16 characters
- **Keep dependencies updated** - Run `npm audit` regularly
- **Configure firewall** - Only expose necessary ports
- **Use HTTPS** - Configure SSL certificates for production

## 🛠️ Troubleshooting

### Services not starting
```bash
# Check PM2 logs
pm2 logs

# Check PM2 status
pm2 status

# Restart services
pm2 restart all
```

### Database connection failed
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Test connection
node packages/backend/database/test-connection.js
```

### Build errors
```bash
# Clean and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear PM2
pm2 delete all
pm2 save
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👤 Author

**Mohammed Ibenayad**

## 🙏 Acknowledgments

- Built with React 19 and modern web technologies
- Follows monorepo best practices with npm workspaces
- Production-ready with automated deployment scripts
- Inspired by industry standard quality management practices
