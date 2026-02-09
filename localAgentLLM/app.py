from flask import Flask, request, jsonify, Response
import sqlite3
import time
from datetime import datetime

DB = "/data/agent.db"
AGENT_KEY = "reXRrDxOI1tY3pe3Rt1WoW3IigHKC4yE"

app = Flask(__name__)

def db():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = db()
    conn.execute("""
    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_at TEXT,
      source TEXT,
      subject TEXT,
      sender TEXT,
      received TEXT,
      body TEXT,
      url TEXT
    )""")
    conn.execute("""
    CREATE TABLE IF NOT EXISTS runs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ran_at TEXT
    )""")
    conn.commit()
    conn.close()

def require_key():
    return request.headers.get("X-Agent-Key") == AGENT_KEY

@app.get("/")
def root():
    return jsonify({
        "ok": True,
        "ui": "/ui",
        "routes": ["/health", "/ui", "/ingest", "/paste", "/messages"]
    })

@app.get("/ui")
def ui():
    html = """<!doctype html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
  <title>Local Agent Inbox</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; margin: 24px; max-width: 980px; }
    .row { display: flex; gap: 16px; flex-wrap: wrap; }
    .card { border: 1px solid #ddd; border-radius: 12px; padding: 14px; flex: 1 1 420px; }
    label { display:block; font-size: 13px; margin: 8px 0 6px; color: #333; }
    input, textarea { width: 100%; box-sizing: border-box; padding: 10px; border-radius: 10px; border: 1px solid #ccc; font-size: 14px; }
    textarea { min-height: 220px; }
    button { padding: 10px 12px; border: 0; border-radius: 10px; cursor: pointer; background: #111; color: #fff; font-size: 14px; }
    button.secondary { background: #444; }
    .muted { color: #666; font-size: 13px; }
    pre { white-space: pre-wrap; word-break: break-word; background: #f7f7f7; padding: 10px; border-radius: 10px; border: 1px solid #eee; }
    table { width: 100%; border-collapse: collapse; }
    th, td { text-align: left; padding: 8px; border-bottom: 1px solid #eee; font-size: 13px; }
    .ok { color: #1b5e20; }
    .err { color: #b00020; }
  </style>
</head>
<body>
  <h1>Local Agent Inbox</h1>
  <p class=\"muted\">Paste an email or meeting notes here. Nothing is sent anywhere except your local app.</p>

  <div class=\"row\">
    <div class=\"card\">
      <h2>Paste</h2>
      <label>Subject (optional)</label>
      <input id=\"subject\" placeholder=\"Optional subject\" />

      <label>From (optional)</label>
      <input id=\"sender\" placeholder=\"Optional sender\" />

      <label>Body</label>
      <textarea id=\"body\" placeholder=\"Paste content here...\"></textarea>

      <div style=\"display:flex; gap:10px; align-items:center; margin-top:10px;\">
        <button id=\"capture\">Capture</button>
        <button class=\"secondary\" id=\"refresh\">Refresh list</button>
        <span id=\"status\" class=\"muted\"></span>
      </div>
    </div>

    <div class=\"card\">
      <h2>Recent captures</h2>
      <div id=\"list\" class=\"muted\">Loading...</div>
    </div>
  </div>

<script>
  const statusEl = document.getElementById('status');
  function setStatus(msg, ok=true) {
    statusEl.textContent = msg;
    statusEl.className = ok ? 'muted ok' : 'muted err';
  }

  async function loadMessages() {
    const res = await fetch('/messages?limit=50');
    const data = await res.json();
    if (!Array.isArray(data) || data.length === 0) {
      document.getElementById('list').innerHTML = '<div class="muted">No captures yet.</div>';
      return;
    }
    let html = '<table><thead><tr><th>When</th><th>From</th><th>Subject</th></tr></thead><tbody>';
    for (const m of data) {
      html += `<tr><td>${(m.created_at||'').slice(0,19).replace('T',' ')}</td><td>${m.sender||''}</td><td>${m.subject||''}</td></tr>`;
    }
    html += '</tbody></table>';
    document.getElementById('list').innerHTML = html;
  }

  document.getElementById('refresh').addEventListener('click', () => {
    loadMessages().catch(e => setStatus('Refresh failed: ' + e.message, false));
  });

  document.getElementById('capture').addEventListener('click', async () => {
    const subject = document.getElementById('subject').value || '';
    const sender = document.getElementById('sender').value || '';
    const body = document.getElementById('body').value || '';
    if (!body.trim()) {
      setStatus('Paste some text first 🙂', false);
      return;
    }

    setStatus('Capturing...');
    const res = await fetch('/paste', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ subject, sender, body })
    });
    const out = await res.json();
    if (!res.ok || !out.ok) {
      setStatus('Capture failed: ' + (out.error || res.status), false);
      return;
    }
    document.getElementById('body').value = '';
    setStatus('Captured ✅');
    await loadMessages();
  });

  loadMessages().catch(e => setStatus('Load failed: ' + e.message, false));
</script>
</body>
</html>"""
    return Response(html, mimetype="text/html")

@app.post("/paste")
def paste():
    data = request.get_json(force=True, silent=True) or {}
    subject = (data.get("subject") or "").strip()
    sender = (data.get("sender") or "").strip()
    body = (data.get("body") or "").strip()

    if not body:
        return jsonify({"ok": False, "error": "empty body"}), 400

    now = datetime.utcnow().isoformat()
    conn = db()
    cur = conn.execute("""
      INSERT INTO messages(created_at, source, subject, sender, received, body, url)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        now,
        "paste",
        subject,
        sender,
        "",
        body,
        ""
    ))
    conn.commit()
    mid = cur.lastrowid
    conn.close()
    return jsonify({"ok": True, "id": mid})
    
@app.post("/ingest")
def ingest():
    if not require_key():
        return jsonify({"ok": False, "error": "unauthorized"}), 401

    data = request.get_json(force=True, silent=True) or {}
    now = datetime.utcnow().isoformat()
    conn = db()
    cur = conn.execute("""
      INSERT INTO messages(created_at, source, subject, sender, received, body, url)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        now,
        data.get("source",""),
        data.get("subject",""),
        data.get("from",""),
        data.get("received",""),
        data.get("body",""),
        data.get("url",""),
    ))
    conn.commit()
    mid = cur.lastrowid
    conn.close()
    return jsonify({"ok": True, "id": mid})

@app.get("/messages")
def messages():
    limit = int(request.args.get("limit", "50"))
    conn = db()
    rows = conn.execute("""
      SELECT id, created_at, source, subject, sender, received, url
      FROM messages ORDER BY id DESC LIMIT ?
    """, (limit,)).fetchall()
    conn.close()
    return jsonify([dict(r) for r in rows])

@app.get("/health")
def health():
    return jsonify({"ok": True})

if __name__ == "__main__":
    import os
    os.makedirs("/data", exist_ok=True)
    init_db()
    app.run(host="0.0.0.0", port=8089)