from flask import Flask, request, jsonify
import sqlite3
import time
from datetime import datetime

DB = "agent.db"
AGENT_KEY = "CHANGE_ME_TO_SOMETHING_RANDOM"

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
    init_db()
    app.run(host="0.0.0.0", port=8089)