from flask import Flask, jsonify
import os

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "1.0.0")
ENV = os.getenv("APP_ENV", "production")

@app.route("/")
def home():
    return jsonify({
        "message": "Zero-Downtime CI/CD Pipeline — Live",
        "version": VERSION,
        "env": ENV,
        "status": "healthy"
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/ready")
def ready():
    return jsonify({"status": "ready"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
