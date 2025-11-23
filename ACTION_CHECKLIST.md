# Action Checklist - Quality Traceability Matrix

Quick reference checklist for implementing the codebase review recommendations.

## 🔴 CRITICAL - Do Immediately (This Week)

### Security Fixes

- [ ] **Remove hardcoded database password**
  ```bash
  git rm --cached docker/.env
  echo "docker/.env" >> .gitignore
  # Generate new password: openssl rand -base64 32
  ```

- [ ] **Require JWT_SECRET environment variable**
  - Edit: `packages/backend/api/middleware/auth.js`
  - Edit: `packages/backend/api/controllers/authController.js`
  - Remove fallback: `|| 'your-secret-key-change-in-production'`
  - Add: `if (!JWT_SECRET) throw new Error('JWT_SECRET required')`

- [ ] **Fix CORS debugging bypass**
  - Edit: `packages/backend/api-server.js` line 44
  - Remove: `callback(null, true); // Allow anyway for debugging`
  - Replace with: `callback(new Error('Not allowed by CORS'))`

- [ ] **Update .env.example files**
  - Remove hardcoded passwords
  - Add comments for required secrets
  - Document password requirements

### Files to Remove

- [ ] **Remove yarn.lock**
  ```bash
  rm packages/frontend/yarn.lock
  cd packages/frontend && npm install
  ```

- [ ] **Clean up git history** (if credentials were committed)
  ```bash
  git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch docker/.env" \
    --prune-empty --tag-name-filter cat -- --all
  ```

---

## 🟡 HIGH PRIORITY - Week 2

### Code Organization

- [ ] **Consolidate context folders**
  ```bash
  mv packages/frontend/src/context/VersionContext.jsx \
     packages/frontend/src/contexts/VersionContext.jsx
  rm -rf packages/frontend/src/context/
  # Update all imports in affected files
  ```

- [ ] **Fix environment variable naming**
  - Edit: `packages/frontend/.env.example`
  - Remove: `REACT_APP_*` variables
  - Keep only: `VITE_*` prefix
  - Update code references

### Testing Setup

- [ ] **Install testing dependencies**
  ```bash
  npm install --save-dev vitest @testing-library/react @testing-library/jest-dom
  npm install --save-dev @testing-library/user-event jsdom
  ```

- [ ] **Create test structure**
  ```bash
  mkdir -p packages/frontend/src/__tests__/{components,services,utils}
  mkdir -p packages/backend/__tests__/{api,database,middleware}
  ```

- [ ] **Add test configuration**
  - Create: `packages/frontend/vitest.config.js`
  - Create: `packages/backend/jest.config.js`
  - Add test scripts to package.json

- [ ] **Write first tests** (minimum)
  - [ ] Auth service tests
  - [ ] Login API endpoint test
  - [ ] Database connection test
  - [ ] Protected route test

---

## 🟢 MEDIUM PRIORITY - Weeks 3-4

### CI/CD Pipeline

- [ ] **Create GitHub Actions workflow**
  - Create: `.github/workflows/ci.yml`
  - Add jobs: test, lint, build, security scan

- [ ] **Add pre-commit hooks**
  ```bash
  npm install --save-dev husky lint-staged
  npx husky install
  ```

- [ ] **Configure automated builds**
  - Docker image building
  - Multi-architecture support

### API Documentation

- [ ] **Install Swagger**
  ```bash
  cd packages/backend
  npm install swagger-ui-express swagger-jsdoc
  ```

- [ ] **Create Swagger config**
  - Create: `packages/backend/api/swagger.js`
  - Add endpoint: `/api-docs`
  - Document existing routes

### Security Enhancements

- [ ] **Add rate limiting**
  ```bash
  npm install express-rate-limit
  ```
  - Create: `packages/backend/api/middleware/rateLimiter.js`
  - Apply to auth routes

- [ ] **Add input validation**
  ```bash
  npm install joi
  ```
  - Create: `packages/backend/api/middleware/validate.js`
  - Add schemas for all endpoints

### Error Tracking

- [ ] **Install Sentry**
  ```bash
  npm install @sentry/react @sentry/node
  ```

- [ ] **Configure Sentry**
  - Frontend: `packages/frontend/src/main.jsx`
  - Backend: `packages/backend/api-server.js`
  - Add SENTRY_DSN to environment variables

---

## 🔵 LOW PRIORITY - Weeks 5+

### Database Optimizations

- [ ] **Add missing indexes**
  ```sql
  CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
  CREATE INDEX idx_test_results_status ON test_results(status, execution_run_id);
  ```

- [ ] **Add constraints**
  ```sql
  CREATE UNIQUE INDEX idx_users_email_lower ON users(LOWER(email));
  ```

### Performance Improvements

- [ ] **Implement code splitting**
  - Add lazy loading for routes
  - Use React.lazy() and Suspense

- [ ] **Add memoization**
  - Use React.memo for expensive components
  - Use useMemo for expensive calculations
  - Use useCallback for stable function references

- [ ] **Add Redis caching**
  ```bash
  npm install redis connect-redis
  ```

### Code Quality

- [ ] **Add error boundaries**
  - Create: `packages/frontend/src/components/ErrorBoundary.jsx`
  - Wrap main app components

- [ ] **Standardize error handling**
  - Create: `packages/backend/api/middleware/errorHandler.js`
  - Implement AppError class
  - Use consistent error responses

- [ ] **Consider TypeScript** (optional)
  ```bash
  npm install --save-dev typescript @types/react @types/react-dom
  ```

### Monitoring

- [ ] **Add structured logging**
  ```bash
  npm install winston
  ```

- [ ] **Set up monitoring dashboards**
  - Prometheus for metrics
  - Grafana for visualization

- [ ] **Add performance monitoring**
  - Frontend: Web Vitals
  - Backend: Response time tracking

---

## ⚪ OPTIONAL ENHANCEMENTS

### Advanced Features

- [ ] **Message queue integration**
  - RabbitMQ or Redis for async processing
  - Worker processes for background jobs

- [ ] **Database read replicas**
  - Set up PostgreSQL replication
  - Route read queries to replicas

- [ ] **API Gateway**
  - Kong or custom gateway
  - Centralized auth and rate limiting

- [ ] **CDN for static assets**
  - CloudFlare or AWS CloudFront
  - Reduce origin load

### Development Experience

- [ ] **Add Storybook** (for UI components)
  ```bash
  npx storybook@latest init
  ```

- [ ] **Add E2E tests**
  ```bash
  npm install --save-dev @playwright/test
  ```

- [ ] **Improve developer documentation**
  - Architecture diagrams
  - Contributing guidelines
  - Code style guide

---

## Progress Tracking

**Phase 1 (Week 1)**: Critical Security
- Items completed: ____ / 4
- Status: ⏳ In Progress / ✅ Complete

**Phase 2 (Week 2)**: Code Quality
- Items completed: ____ / 6
- Status: ⏳ In Progress / ✅ Complete

**Phase 3 (Weeks 3-4)**: Testing & DevOps
- Items completed: ____ / 8
- Status: ⏳ In Progress / ✅ Complete

**Phase 4 (Week 5+)**: Optimization
- Items completed: ____ / 12
- Status: ⏳ In Progress / ✅ Complete

---

## Quick Commands Reference

### Security
```bash
# Remove sensitive files from git
git rm --cached docker/.env

# Generate strong password
openssl rand -base64 32

# Check for secrets in code
grep -r "password\|secret\|key" --exclude-dir=node_modules
```

### Testing
```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Watch mode
npm test -- --watch
```

### Docker
```bash
# Rebuild containers
docker compose down -v
docker compose build --no-cache
docker compose up -d

# View logs
docker compose logs -f

# Security scan
docker scan quality-tracker-backend
```

### Database
```bash
# Connect to database
docker compose exec postgres psql -U quality_tracker_user -d quality_tracker_db

# Run migrations
npm run db:migrate

# Seed data
npm run db:seed
```

---

**Last Updated**: 2025-11-23
**Review Date**: After completing each phase
