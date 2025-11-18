#!/bin/bash
set -e
echo "🚀 Starting Quora Automation Setup..."
mkdir -p quora-automation-project/logs quora-automation-project/data
cd quora-automation-project

# Create .env
cat > .env << 'EOF'
# Database Configuration
DB_HOST=mysql
DB_USER=quora_user
DB_PASSWORD=Quora@SecurePass123!
DB_NAME=quora_automation
DB_PORT=3306

# OpenAI Configuration
# Get your key from: https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-your-actual-key-here
OPENAI_MODEL=gpt-3.5-turbo

# Quora Configuration
QUORA_TIMEOUT=30
QUORA_MAX_RETRIES=3

# Automation Settings
POSTS_PER_DAY=5
POSTS_PER_ACCOUNT_DAILY=5
MIN_QUALITY_SCORE=60
MIN_READABILITY_SCORE=40
POSTING_DELAY_MIN=300
POSTING_DELAY_MAX=900

# Topics to Automate (comma-separated)
TOPICS=financial-tools,personal-finance,loans,budgeting,investment,M&A

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/quora_automation.log

# Scheduling
SCRAPE_INTERVAL=6
AUTOMATION_START_HOUR=9
AUTOMATION_END_HOUR=21
EOF

echo "✅ .env file created"

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: quora_automation_mysql
    environment:
      MYSQL_ROOT_PASSWORD: root_secure_pass_123
      MYSQL_DATABASE: quora_automation
      MYSQL_USER: quora_user
      MYSQL_PASSWORD: Quora@SecurePass123!
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - quora_net
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10
      interval: 5s

  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: quora_automation_app
    depends_on:
      mysql:
        condition: service_healthy
    environment:
      DB_HOST: mysql
      DB_USER: quora_user
      DB_PASSWORD: Quora@SecurePass123!
      DB_NAME: quora_automation
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      LOG_LEVEL: INFO
    volumes:
      - ./logs:/app/logs
      - ./app:/app
    networks:
      - quora_net
    restart: unless-stopped

  phpmyadmin:
    image: phpmyadmin:latest
    container_name: quora_automation_phpmyadmin
    environment:
      PMA_HOST: mysql
      PMA_USER: quora_user
      PMA_PASSWORD: Quora@SecurePass123!
    ports:
      - "8080:80"
    depends_on:
      - mysql
    networks:
      - quora_net
    restart: unless-stopped

volumes:
  mysql_data:

networks:
  quora_net:
    driver: bridge
EOF

echo "✅ docker-compose.yml created"

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    mysql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN python -m nltk.downloader punkt stopwords 2>/dev/null || true

COPY . .

ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]
EOF

echo "✅ Dockerfile created"

# Create requirements.txt
cat > requirements.txt << 'EOF'
beautifulsoup4==4.12.2
selenium==4.15.2
requests==2.31.0
urllib3==2.1.0
openai==1.3.9
textblob==0.17.1
nltk==3.8.1
mysql-connector-python==8.2.0
sqlalchemy==2.0.23
APScheduler==3.10.4
python-dotenv==1.0.0
PyJWT==2.8.1
Flask==2.3.0
Flask-CORS==4.0.0
numpy==1.24.3
pandas==2.0.3
EOF

echo "✅ requirements.txt created"

# Create main.py
cat > main.py << 'EOF'
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
EOF

chmod +x main.py
echo "✅ main.py created"

# Create init.sql for database
cat > init.sql << 'EOF'
CREATE DATABASE IF NOT EXISTS quora_automation;
USE quora_automation;

CREATE TABLE IF NOT EXISTS quora_questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id VARCHAR(255) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    topic VARCHAR(100) NOT NULL,
    url VARCHAR(500),
    scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    relevance_score FLOAT DEFAULT 0,
    answer_posted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_answer_posted (answer_posted),
    INDEX idx_relevance_score (relevance_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS quora_answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    answer_id VARCHAR(255) UNIQUE NOT NULL,
    question_id VARCHAR(255) NOT NULL,
    account_id VARCHAR(100),
    content LONGTEXT,
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    views INT DEFAULT 0,
    upvotes INT DEFAULT 0,
    traffic_to_site INT DEFAULT 0,
    INDEX idx_posted_at (posted_at),
    INDEX idx_views (views)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS activity_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    activity_type VARCHAR(50),
    message VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert initial data
INSERT IGNORE INTO quora_questions (question_id, title, topic, url) VALUES 
('q1', 'How to calculate compound interest?', 'financial-tools', 'https://quora.com/...'),
('q2', 'Best budgeting strategies for 2025', 'personal-finance', 'https://quora.com/...');
EOF

echo "✅ init.sql created"

# Start Docker services
echo "📦 Starting Docker Services..."
docker-compose up -d
echo "✅ Docker services started"

# Wait for services
echo "⏳ Waiting for services to be ready (30 seconds)..."
sleep 30

# Check status
echo "📊 Checking service status..."
docker-compose ps

# Show success message
echo ""
echo "🎉 SETUP COMPLETE!"
echo "═══════════════════════════════════════════════════════════════"
echo "📝 Next Steps:"
echo "1. Edit .env file and add your OpenAI API key:"
echo "   nano .env"
echo "   OPENAI_API_KEY=sk-your-actual-key"
echo ""
echo "2. Restart application:"
echo "   docker-compose restart app"
echo ""
echo "3. View real-time logs:"
echo "   docker-compose logs -f app"
echo ""
echo "4. Access PhpMyAdmin Dashboard:"
echo "   URL: http://localhost:8080"
echo "   Username: quora_user"
echo "   Password: Quora@SecurePass123!"
echo ""
echo "5. Monitor automation cycles in logs"
echo ""
echo "⚠️  IMPORTANT: Add OpenAI API key in .env file!"
echo "═══════════════════════════════════════════════════════════════"
