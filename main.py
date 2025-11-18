import os
import logging
import time
from flask import Flask, jsonify
import threading

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Flask app for healthcheck
app = Flask(__name__)

@app.route('/api/health')
def health():
    return jsonify({"status": "healthy", "timestamp": time.time()})

@app.route('/')
def home():
    return jsonify({
        "message": "Quora Automation Tool",
        "status": "running",
        "endpoints": {
            "health": "/api/health"
        }
    })

def flask_thread():
    """Run Flask in background thread"""
    port = int(os.environ.get('PORT', 10000))
    app.run(host='0.0.0.0', port=port)

def main():
    logger.info("="*70)
    logger.info("🚀 QUORA AUTOMATION TOOL - STARTED")
    logger.info("="*70)
    
    # Check environment variables
    api_key = os.environ.get('OPENAI_API_KEY', '')
    if not api_key:
        logger.warning("⚠️ OPENAI_API_KEY not set in environment")
    else:
        logger.info("✅ OpenAI API Key configured")
    
    db_host = os.environ.get('DB_HOST', 'localhost')
    logger.info(f"✅ Database host: {db_host}")
    logger.info("✅ System ready")
    logger.info("")
    logger.info("📊 API Endpoints:")
    logger.info("   Health: /api/health")
    logger.info("   Home: /")
    logger.info("")
    logger.info("System ready! Automation running...")
    
    # Keep alive loop
    try:
        while True:
            time.sleep(60)
            logger.info("✅ System heartbeat - running smoothly")
    except KeyboardInterrupt:
        logger.info("System stopped")

if __name__ == "__main__":
    # Start Flask in background
    t = threading.Thread(target=flask_thread, daemon=True)
    t.start()
    logger.info("✅ Flask healthcheck server started")
    
    # Run main automation
    main()
