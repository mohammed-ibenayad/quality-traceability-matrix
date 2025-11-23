# Quality Traceability Matrix

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
quality-traceability-matrix/
├── packages/
│   ├── frontend/           # React application (Vite + React 19)
│   │   ├── src/
│   │   │   ├── components/ # Reusable UI components
│   │   │   │   ├── Dashboard/
│   │   │   │   ├── TraceabilityMatrix/
│   │   │   │   ├── TestExecution/
│   │   │   │   ├── Requirements/
│   │   │   │   ├── TestCases/
│   │   │   │   └── Layout/
│   │   │   ├── pages/      # Page components
│   │   │   ├── hooks/      # Custom React hooks
│   │   │   ├── contexts/   # React context
│   │   │   ├── api/        # API integration
│   │   │   ├── utils/      # Utility functions
│   │   │   └── data/       # Sample data
│   │   ├── public/         # Static assets
│   │   └── index.html      # HTML entry point
│   │
│   └── backend/            # Node.js/Express API servers
│       ├── api/
│       │   ├── routes/     # API endpoints
│       │   ├── controllers/
│       │   └── middleware/
│       ├── database/
│       │   ├── init/       # Schema SQL files
│       │   └── seeds/      # Seed data
│       ├── api-server.js   # API server (port 3002)
│       └── webhook-server.js # Webhook server (port 3001)
│
├── scripts/                # Deployment and utility scripts
├── docs/                   # Documentation
├── docker/                 # Docker configurations
├── package.json            # Root workspace configuration
└── .env.example            # Environment variables template
```

## 📦 Packages

### Frontend (`packages/frontend`)
- **Framework**: React 19 with Vite
- **Styling**: TailwindCSS 3
- **Routing**: React Router 7
- **Visualization**: Recharts
- **Real-time**: Socket.io Client
- **HTTP**: Axios
- **GitHub**: Octokit

### Backend (`packages/backend`)
- **Framework**: Node.js with Express
- **Database**: PostgreSQL (19 tables)
- **Real-time**: Socket.io
- **Auth**: JWT
- **Process Management**: PM2

**Two Servers:**
- **Webhook Server** (Port 3001): Receives test execution results
- **API Server** (Port 3002): REST API for CRUD operations

## 🚀 Getting Started

### Prerequisites

- Node.js >= 16.0.0
- npm >= 8.0.0
- PostgreSQL >= 12 (for production)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mohammed-ibenayad/quality-traceability-matrix.git
   cd quality-traceability-matrix
   ```

2. **Install all dependencies**
   ```bash
   npm install
   ```
   This installs dependencies for both frontend and backend using npm workspaces.

3. **Set up environment variables**
   ```bash
   # Copy environment templates
   cp .env.example .env
   cp packages/frontend/.env.example packages/frontend/.env
   cp packages/backend/.env.example packages/backend/.env
   ```

   Edit the `.env` files with your configuration (database credentials, API URLs, etc.).

4. **Set up the database** (if using PostgreSQL)
   ```bash
   # Run database migration
   npm run db:migrate

   # Seed with sample data (optional)
   npm run db:seed

   # Test database connection
   npm run db:test
   ```

### Development

**Start both frontend and backend simultaneously:**
```bash
npm run dev
```

This will start:
- Frontend at http://localhost:5173
- Webhook Server at http://localhost:3001
- API Server at http://localhost:3002

**Start services individually:**
```bash
npm run dev:frontend  # Frontend only
npm run dev:backend   # Backend webhook server
npm run dev:api       # Backend API server
```

### Production Build

**Build frontend:**
```bash
npm run build
```

**Start backend servers:**
```bash
npm run start:backend    # Both servers via PM2
npm run start:api        # API server only
```

## 🐳 Docker Deployment

### Using Docker Compose (Recommended)

**Production:**
```bash
cd docker
docker-compose up -d
```

**Development:**
```bash
cd docker
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

**Access services:**
- Frontend: http://localhost:80
- API Server: http://localhost:3002
- Webhook Server: http://localhost:3001
- PostgreSQL: localhost:5432

**Stop services:**
```bash
docker-compose down
```

**View logs:**
```bash
docker-compose logs -f
```

## 📝 Available Scripts

### Root Level Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start both frontend and backend in dev mode |
| `npm run dev:frontend` | Start frontend dev server (port 5173) |
| `npm run dev:backend` | Start backend webhook server in dev mode |
| `npm run dev:api` | Start backend API server in dev mode |
| `npm run build` | Build frontend for production |
| `npm run build:all` | Build all packages |
| `npm run start:backend` | Start backend servers with PM2 |
| `npm run start:api` | Start API server only |
| `npm run lint` | Run linting on all packages |
| `npm run test` | Run tests on all packages |
| `npm run db:test` | Test database connection |
| `npm run db:seed` | Seed database with sample data |
| `npm run db:migrate` | Run database migrations |

## 🔧 Technology Stack

### Frontend
- React 19.0.0
- Vite 6.2.0
- TailwindCSS 3.3.5
- React Router 7.3.0
- Recharts 2.15.1
- Socket.io Client 4.8.1
- Axios 1.6.8
- Octokit (GitHub API)

### Backend
- Node.js 16+
- Express 4.21.2
- PostgreSQL (pg 8.16.3)
- Socket.io 4.8.1
- JWT (jsonwebtoken 9.0.2)
- PM2 (process management)

### DevOps
- Docker & Docker Compose
- Nginx (production frontend)
- npm Workspaces (monorepo)
- concurrently (parallel scripts)

## 📊 Database Schema

PostgreSQL database with **19 tables**:
- User management (`users`, `workspaces`, `projects`)
- Requirements (`requirements`, `versions`)
- Test management (`test_cases`, `test_suites`, `test_executions`)
- Traceability (`requirement_test_mapping`)
- Quality (`quality_gates`, `risk_assessments`)
- Releases (`releases`, `release_requirements`)
- Audit (`webhook_logs`, `audit_logs`)

## 🔐 Environment Variables

**Frontend (.env):**
```env
VITE_API_URL=http://localhost:3002
REACT_APP_WEBHOOK_URL=http://localhost:3001
REACT_APP_BACKEND_ENABLED=true
```

**Backend (.env):**
```env
NODE_ENV=development
API_PORT=3002
PORT=3001
DB_HOST=localhost
DB_NAME=quality_tracker_db
DB_USER=your_db_user
DB_PASSWORD=your_db_password
```

See `.env.example` files for all available options.

## 📚 Documentation

- [Test Depth Factor (TDF)](./docs/ABOUT-TDF.md) - Understanding the quality metric
- [API Documentation](./docs/API.md) - REST API endpoints _(coming soon)_
- [Database Schema](./docs/DATABASE.md) - Database structure _(coming soon)_

## 🎨 Customizing the Application

### Adding Real Data

Replace sample data in `packages/frontend/src/data/`:
- `requirements.js`: Your project requirements
- `testcases.js`: Your test cases
- `versions.js`: Release versions
- `mapping.js`: Requirement-test relationships

### Customizing Test Depth Factor

Modify `packages/frontend/src/utils/coverage.js` to adjust TDF calculation based on your needs.

## 🛣️ Planned Enhancements

- [ ] User authentication and RBAC
- [ ] Advanced test case editor
- [ ] CI/CD integration (Jenkins, CircleCI, GitHub Actions)
- [ ] Export to PDF/Excel
- [ ] Historical trend analysis
- [ ] Mobile responsive dashboard
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Unit and integration tests

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
- Production-ready Docker configuration
- Inspired by industry standard quality management practices
