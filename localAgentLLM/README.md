# Local Agent Inbox

A lightweight local Flask app for capturing message text and generating reply-focused digests using an Ollama model.

## What this project does

- Stores pasted notes/messages in a local SQLite database (`/data/agent.db`).
- Provides a simple browser UI to capture messages, view recent captures, run digest generation, and clear/reset stored data.
- Calls Ollama (`/api/chat`) to generate a concise "what needs a reply" digest.

## Project files

- `app.py`: Flask API + built-in HTML UI
- `docker-compose.yml`: runs app + Ollama together
- `dockerfile`: image for the Flask app
- `data/`: persisted SQLite database (mounted in Docker)

## Requirements

### Docker path (recommended)

- Docker Desktop (or Docker Engine with Compose)

### Local Python path

- Python 3.10+ (project uses Python 3.12 in Docker)
- `pip` packages: `flask`, `requests`
- Running Ollama instance with a compatible model

## Run with Docker Compose

From this directory:

```bash
docker compose up --build
```

Then open:

- UI: [http://localhost:8089/ui](http://localhost:8089/ui)
- Health check: [http://localhost:8089/health](http://localhost:8089/health)

Notes:

- The API container stores DB data in `./data` via volume mount.
- `docker-compose.yml` sets `OLLAMA_BASE_URL=http://ollama:11434` and `OLLAMA_MODEL=llama3.2:3b`.

## Run locally (without Docker for Flask app)

1. Install dependencies:

```bash
python3 -m pip install flask requests
```

2. Ensure Ollama is running (default expected URL: `http://localhost:11434`) and the model exists:

```bash
ollama pull llama3.2:3b
```

3. Start the app:

```bash
python3 app.py
```

4. Open:

- UI: [http://localhost:8089/ui](http://localhost:8089/ui)

## API endpoints

- `GET /` basic service metadata
- `GET /health` health probe
- `GET /ui` built-in web UI
- `POST /paste` capture one message
- `GET /messages?limit=50` list recent captures
- `POST /run` generate digest from new messages
- `GET /digest/latest` fetch latest digest
- `POST /messages/clear` delete captured messages
- `POST /reset` delete messages, digests, and run history

## Example capture request

```bash
curl -X POST http://localhost:8089/paste \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Status update needed",
    "sender": "manager@example.com",
    "body": "Can you send me project status and ETA by EOD?"
  }'
```

## Configuration

Environment variables used by `app.py`:

- `OLLAMA_BASE_URL` (default: `http://localhost:11434`)
- `OLLAMA_MODEL` (default: `llama3.2:3b`)

## Troubleshooting

- `Digest generation failed`: confirm Ollama is running and model is available.
- Empty UI list: confirm captures were posted to `/paste`.
- Port conflict on `8089`: stop conflicting process or remap port in `docker-compose.yml`.
