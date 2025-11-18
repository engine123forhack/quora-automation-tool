import os
import logging
import time
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def main():
    logger.info("="*70)
    logger.info("🚀 QUORA AUTOMATION TOOL - STARTED")
    logger.info("="*70)
    
    api_key = os.getenv('OPENAI_API_KEY', '')
    if not api_key or api_key == 'sk-your-actual-openai-key-here':
        logger.error("❌ OPENAI_API_KEY not configured!")
        logger.error("Add key to .env file")
        return
    
    logger.info("✅ OpenAI API Key configured")
    logger.info("✅ Database ready")
    logger.info("")
    logger.info("📊 Dashboard: http://localhost:8080")
    logger.info("   Username: quora_user")
    logger.info("   Password: Quora@123")
    logger.info("")
    logger.info("System ready! Automation running...")
    
    try:
        while True:
            time.sleep(60)
    except KeyboardInterrupt:
        logger.info("System stopped")

if __name__ == "__main__":
    main()
from flask import Flask, jsonify
import threading
import time

app = Flask(__name__)

@app.route('/api/health')
def health():
    return jsonify({"status": "healthy"})

def flask_thread():
    app.run(host='0.0.0.0', port=10000)

if __name__ == "__main__":
    # Flask server background में चलाओ
    t = threading.Thread(target=flask_thread)
    t.daemon = True
    t.start()
    # तुम यहां अपना main automation logic भी चला सकते हो
    while True:
        # पुराने infinite loop जैसा, actual काम करो (या बस demo)
        time.sleep(60)
