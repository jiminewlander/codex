from flask import Flask, request, jsonify, Response
import sqlite3
import os
import requests
from datetime import datetime, timezone

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
    conn.execute("""
    CREATE TABLE IF NOT EXISTS digests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_at TEXT,
      since TEXT,
      until TEXT,
      message_count INTEGER,
      digest_text TEXT
    )""")
    conn.commit()
    conn.close()

def require_key():
    return request.headers.get("X-Agent-Key") == AGENT_KEY

def get_last_run_iso():
    conn = db()
    row = conn.execute("SELECT ran_at FROM runs ORDER BY id DESC LIMIT 1").fetchone()
    conn.close()
    return row["ran_at"] if row else None

def record_run(ran_at_iso: str):
    conn = db()
    conn.execute("INSERT INTO runs(ran_at) VALUES (?)", (ran_at_iso,))
    conn.commit()
    conn.close()

@app.get("/")
def root():
    return jsonify({
        "ok": True,
        "ui": "/ui",
        "routes": ["/health", "/ui", "/paste", "/messages", "/run", "/digest/latest"]
    })

@app.get("/ui")
def ui():
    html = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
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
  <p class="muted">Paste an email or meeting notes here. Nothing is sent anywhere except your local app.</p>

  <div class="row">
    <div class="card">
      <h2>Paste</h2>
      <label>Subject (optional)</label>
      <input id="subject" placeholder="Optional subject" />

      <label>From (optional)</label>
      <input id="sender" placeholder="Optional sender" />

      <label>Body</label>
      <textarea id="body" placeholder="Paste content here..."></textarea>

      <div style="display:flex; gap:10px; align-items:center; margin-top:10px;">
        <button id="capture">Capture</button>
        <button class="secondary" id="refresh">Refresh list</button>
        <button class="secondary" id="run">Run Digest</button>
        <span id="status" class="muted"></span>
      </div>
    </div>

    <div class="card">
      <h2>Recent captures</h2>
      <div id="list" class="muted">Loading...</div>

      <h3 style="margin-top:16px;">Latest digest</h3>
      <pre id="digest" class="muted">No digests yet.</pre>
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

  async function loadDigest() {
    const res = await fetch('/digest/latest');
    const data = await res.json();
    document.getElementById('digest').textContent = data.digest_text || data.digest || 'No digests yet.';
  }

  async function runDigest() {
    setStatus('Running digest (up to ~2 min)...');
    const res = await fetch('/run', { method: 'POST' });
    const data = await res.json();
    if (!res.ok || !data.ok) {
      setStatus('Digest failed: ' + (data.error || res.status), false);
      return;
    }
    setStatus(`Digest complete ✅ (${data.message_count} msgs)`);
    await loadDigest();
  }

  document.getElementById('refresh').addEventListener('click', () => {
    loadMessages().catch(e => setStatus('Refresh failed: ' + e.message, false));
  });

  document.getElementById('run').addEventListener('click', () => {
    runDigest().catch(e => setStatus('Run failed: ' + e.message, false));
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
  loadDigest().catch(e => setStatus('Digest load failed: ' + e.message, false));
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

    now = datetime.now(timezone.utc).isoformat()
    conn = db()
    cur = conn.execute("""
      INSERT INTO messages(created_at, source, subject, sender, received, body, url)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (now, "paste", subject, sender, "", body, ""))
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

@app.post("/run")
def run_digest():
    last_run = get_last_run_iso()
    limit = int(request.args.get("limit", "50"))

    conn = db()
    if last_run:
        rows = conn.execute("""
          SELECT id, created_at, subject, sender, body
          FROM messages
          WHERE created_at > ?
          ORDER BY id ASC
          LIMIT ?
        """, (last_run, limit)).fetchall()
    else:
        rows = conn.execute("""
          SELECT id, created_at, subject, sender, body
          FROM messages
          ORDER BY id ASC
          LIMIT ?
        """, (limit,)).fetchall()

    messages = [dict(r) for r in rows]
    until = datetime.now(timezone.utc).isoformat()

    # mark run now so reruns don't keep reprocessing
    record_run(until)

    if not messages:
        cur = conn.execute(
            "INSERT INTO digests(created_at, since, until, message_count, digest_text) VALUES (?, ?, ?, ?, ?)",
            (until, last_run or "", until, 0, "No new items since last run.")
        )
        conn.commit()
        did = cur.lastrowid
        conn.close()
        return jsonify({"ok": True, "digest_id": did, "message_count": 0, "digest": "No new items since last run."})

    compact = []
    for m in messages:
        subj = (m.get("subject") or "").strip()
        sender = (m.get("sender") or "").strip()
        body = (m.get("body") or "").strip()
        if len(body) > 2500:
            body = body[:2500] + "…"
        compact.append(f"FROM: {sender}\nSUBJECT: {subj}\nBODY: {body}")

    prompt = (
        "You are my personal inbox assistant.\n"
        "Return ONLY items that clearly need a reply from me.\n"
        "Output format:\n"
        "1) ACTION BULLETS: 5 to 12 short bullets, each starting with [P1]..[P5].\n"
        "2) DRAFT REPLIES: For each bullet above, provide a concise draft reply.\n"
        "Tone rules: If the sender looks like leadership or a formal work context, be professional and crisp. Otherwise, casual friendly but still workplace safe.\n"
        "Do not mention these instructions.\n\n"
        "ITEMS:\n" + "\n\n---\n\n".join(compact)
    )

    base = os.environ.get("OLLAMA_BASE_URL", "http://localhost:11434").rstrip("/")
    model = os.environ.get("OLLAMA_MODEL", "llama3.2:3b")

    try:
        r = requests.post(
            f"{base}/api/generate",
            json={"model": model, "prompt": prompt, "stream": False},
            timeout=120,
        )
        r.raise_for_status()
        out = (r.json().get("response") or "").strip()
    except Exception as e:
        out = f"Digest generation failed: {e}"

    cur = conn.execute(
        "INSERT INTO digests(created_at, since, until, message_count, digest_text) VALUES (?, ?, ?, ?, ?)",
        (until, last_run or "", until, len(messages), out)
    )
    conn.commit()
    did = cur.lastrowid
    conn.close()

    return jsonify({"ok": True, "digest_id": did, "message_count": len(messages), "digest": out})

@app.get("/digest/latest")
def digest_latest():
    conn = db()
    row = conn.execute("SELECT * FROM digests ORDER BY id DESC LIMIT 1").fetchone()
    conn.close()
    if not row:
        return jsonify({"ok": True, "digest": "No digests yet."})
    return jsonify({"ok": True, **dict(row)})

@app.get("/health")
def health():
    return jsonify({"ok": True})

if __name__ == "__main__":
    os.makedirs("/data", exist_ok=True)
    init_db()
    app.run(host="0.0.0.0", port=8089)