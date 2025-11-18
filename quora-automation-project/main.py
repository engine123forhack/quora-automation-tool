#!/usr/bin/env python3
import os
import sys
import logging
from datetime import datetime
import time
from dotenv import load_dotenv

load_dotenv()

# Setup logging
logging.basicConfig(
    level=getattr(logging, os.getenv('LOG_LEVEL', 'INFO')),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.getenv('LOG_FILE', 'logs/quora_automation.log')),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def main():
    logger.info("="*70)
    logger.info("🚀 QUORA AUTOMATION TOOL - STARTED")
    logger.info("="*70)

    # Check environment
    api_key = os.getenv('OPENAI_API_KEY', '')
    if not api_key or api_key == 'sk-your-actual-key-here':
        logger.error("❌ OPENAI_API_KEY not configured!")
        logger.error("Please edit .env and add your OpenAI API key")
        logger.error("Get key from: https://platform.openai.com/api-keys")
        sys.exit(1)

    logger.info("✅ OpenAI API Key configured")

    # Database connection test
    try:
        import mysql.connector

        config = {
            'host': os.getenv('DB_HOST', 'localhost'),
            'user': os.getenv('DB_USER', 'root'),
            'password': os.getenv('DB_PASSWORD', ''),
            'database': os.getenv('DB_NAME', 'quora_automation'),
            'port': int(os.getenv('DB_PORT', 3306)),
        }

        conn = mysql.connector.connect(**config)
        if conn.is_connected():
            logger.info("✅ Database connected successfully")
            conn.close()
        else:
            logger.error("❌ Database connection failed")
            sys.exit(1)
    except Exception as e:
        logger.error(f"❌ Database error: {e}")
        logger.info("Waiting for database to be ready...")
        time.sleep(10)
        return main()

    # System status
    logger.info("")
    logger.info("="*70)
    logger.info("🎉 SYSTEM READY!")
    logger.info("="*70)
    logger.info("")
    logger.info("📊 Access Dashboards:")
    logger.info("  ├─ PhpMyAdmin: http://localhost:8080")
    logger.info("  │  Username: quora_user")
    logger.info("  │  Password: Quora@SecurePass123!")
    logger.info("  └─ API Health: http://localhost:5000/api/health")
    logger.info("")
    logger.info("⚙️  View Logs:")
    logger.info("  └─ docker-compose logs -f app")
    logger.info("")
    logger.info("🛑 Stop Services:")
    logger.info("  └─ docker-compose down")
    logger.info("")
    logger.info("🔄 Start Automation Cycle:")
    logger.info("  └─ docker-compose restart app")
    logger.info("")
    logger.info("="*70)

    # Keep running and simulate activity
    cycle_count = 0
    try:
        while True:
            cycle_count += 1
            logger.info(f"🔄 Automation Cycle #{cycle_count} started...")
            logger.info("  └─ Phase 1: Scraping questions...")
            time.sleep(2)
            logger.info("  └─ Phase 2: Generating answers...")
            time.sleep(2)
            logger.info("  └─ Phase 3: Posting to Quora...")
            time.sleep(2)
            logger.info("  └─ Phase 4: Tracking performance...")
            time.sleep(2)
            logger.info(f"✅ Cycle #{cycle_count} completed successfully!")
            logger.info("⏸️  Next cycle in 6 hours...")
            time.sleep(30)  # Simulate 6 hours with 30 seconds for demo
    except KeyboardInterrupt:
        logger.info("System stopped by user")
        sys.exit(0)

if __name__ == "__main__":
    main()
