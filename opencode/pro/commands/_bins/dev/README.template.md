# Development Servers

This project uses `npx dev` for local server management with automatic port allocation.

## Quick Start

```bash
npx dev                  # Start first server
npx dev start web        # Start web server
npx dev stop             # Stop all servers
npx dev status           # Show running servers
```

## Commands

| Command | Description |
|---------|-------------|
| `npx dev start [name]` | Start server (first server if no name) |
| `npx dev stop [name]` | Stop server (all servers if no name) |
| `npx dev restart <name>` | Restart a specific server |
| `npx dev status` | Show running servers with health checks |
| `npx dev logs [name]` | Follow server logs |
| `npx dev doctor` | Diagnose environment issues |
| `npx dev cleanup` | Remove stale PID entries |
| `npx dev init` | Re-initialize from package.json |

**Shorthand:** `npx dev <name>` is equivalent to `npx dev start <name>`

## Configuration

Servers are configured in `.dev/servers.json`:

```json
{
  "web": {
    "command": "npm run dev -- -p {PORT}",
    "preferredPort": 3000,
    "healthCheck": "http://localhost:{PORT}"
  }
}
```

### Configuration Options

| Field | Description |
|-------|-------------|
| `command` | Shell command to start the server. Use `{PORT}` as placeholder. |
| `preferredPort` | Preferred port number. If busy, next available port is used. |
| `healthCheck` | URL to verify server is running. Use `{PORT}` as placeholder. |

## Port Management

- Each server has a `preferredPort` in config
- If the preferred port is in use, the next available port is automatically assigned
- Port mappings are tracked in `.dev/pid.json`
- Status shows `:preferred→actual` when ports differ (e.g., `:3000→3001`)

## File Structure

```
.dev/
├── servers.json   # Server configuration (tracked in git)
├── pid.json       # Runtime process info (gitignored)
├── log/           # Server logs (gitignored)
│   └── web.log
└── README.md      # This file
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DEV_LOG_VIEWER` | Custom log viewer command (default: `tail -f`) |
| `ENABLE_NOTIFICATIONS` | Set to `false` to disable OS notifications |

## Troubleshooting

### Server won't start
1. Check if port is in use: `lsof -i :PORT`
2. View logs: `npx dev logs <name>`
3. Run doctor: `npx dev doctor`

### Orphaned processes
```bash
npx dev cleanup    # Clean stale PID entries
npx dev stop       # Stop all managed servers
```

### Port stuck after crash
```bash
npx dev restart <name>   # Kills any process on preferred port
```
