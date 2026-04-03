# Handoff Report Template

> This template is shared by `/pro:handoff` and `/pro:wtf` commands.

---

## Report Sections

### 1. Project Overview
- **Project name and description** (from README, package.json, or similar)
- **Version** (current version number)
- **License**
- **Repository URL** (if available)
- **Primary language(s) and framework(s)**
- **Project type** (web app, mobile app, API, CLI, library, monorepo, etc.)
- **Mission/purpose statement** (1-2 sentences summarizing what this does)

### 2. Tech Stack

#### Frontend (if applicable)
- Framework and version
- UI library/component system
- State management
- Styling approach
- Build tooling

#### Backend (if applicable)
- Runtime and version
- Framework and version
- Database(s) and ORM/query layer
- Caching layer
- Message queues/background jobs

#### Infrastructure
- Hosting/deployment platform
- CI/CD system
- Container/orchestration (Docker, K8s, etc.)
- CDN/edge services

#### External Services & Integrations
List all third-party services with their purpose:
- Authentication provider
- Payment processor
- Email service
- Analytics/monitoring
- AI/ML services
- Other APIs

### 3. Architecture

#### Directory Structure
Provide a high-level tree of the main directories with brief descriptions of each.

#### Key Architectural Patterns
- Design patterns used (MVC, Repository, Factory, etc.)
- Data flow patterns
- API design style (REST, GraphQL, RPC)
- Error handling strategy
- Logging/observability approach

### 4. Development Workflow

- How to install dependencies
- How to run the project locally
- How to run tests
- How to lint/format
- How to build
- How to run migrations/seeds (if applicable)

### 5. Operations

- Environments (dev/staging/prod)
- Deployment process
- Monitoring/alerting
- Logging
- Backups / restore

### 6. Security

- Secrets management
- Authn/authz model
- Data protection considerations
- Known security gaps

### 7. Testing

- Test types present
- How to run them
- Coverage notes

### 8. Known Risks / Gotchas

- Non-obvious behaviors
- Common failure modes
- Workarounds and pitfalls

---

## Footer

- Report generated:
- Git commit:
- Generator:
