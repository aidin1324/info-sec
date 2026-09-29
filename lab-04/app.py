#!/usr/bin/env python3
"""Local, visibly labelled phishing-awareness simulator using fixed dummy data."""

import json
from pathlib import Path

from flask import Flask, jsonify, render_template, request

BASE = Path(__file__).resolve().parent
DEMO = {"holder": "DEMO STUDENT", "card": "0000 0000 0000 0000",
        "expiry": "12/99", "cvv": "000"}


def create_app(record_path=None):
    app = Flask(__name__, template_folder=str(BASE / "templates"))
    app.config["MAX_CONTENT_LENGTH"] = 4096
    record = Path(record_path) if record_path is not None else BASE / "runtime/submissions.jsonl"

    @app.get("/")
    def index():
        return render_template("index.html", demo=DEMO)

    @app.post("/submit")
    def submit():
        payload = request.get_json(silent=True)
        # This check belongs on the server: browser readonly attributes can be removed.
        if not isinstance(payload, dict) or payload != DEMO:
            return jsonify(error="Only the fixed fictional training values are accepted."), 400
        record.parent.mkdir(parents=True, exist_ok=True)
        with record.open("a", encoding="utf-8") as output:
            output.write(json.dumps(DEMO, ensure_ascii=False) + "\n")
        return jsonify(saved=True, demo_only=True), 201

    return app


if __name__ == "__main__":
    create_app().run(host="127.0.0.1", port=8040, debug=False)
