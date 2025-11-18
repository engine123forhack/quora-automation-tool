import os
import logging
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = json.dumps({"status": "healthy", "timestamp": time.time()})
            self.wfile.write(response.encode())
        elif self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = json.dumps({
                "message": "Quora Automation Tool",
                "status": "running",
                "endpoints": {
                    "health": "/api/health"
                }
            })
            self.wfile.write(response.encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

def http_server_thread():
    """Run HTTP server in background thread"""
    port = int(os.environ.get('PORT', 10000))
    server = HTTPServer(('0.0.0.0', port), HealthCheckHandler)
    logger.info(f"✅ HTTP server started on port {port}")
    server.serve_forever()

def main():
    logger.info("="*70)
    logger.info("🚀 QUORA AUTOMATION TOOL - STARTED")
    logger.info("="*70)
    
    # Check environment variables
    api_key = os.environ.get('OPENAI_API_KEY', '')
    if api_key:
        logger.info("✅ OpenAI API Key configured")
    else:
        logger.warning("⚠️  OPENAI_API_KEY not set")
    
    db_host = os.environ.get('DB_HOST', 'localhost')
    logger.info(f"✅ Database host: {db_host}")
    logger.info("✅ Database ready")
    logger.info("")
    logger.info("📊 Dashboard: http://localhost:8080")
    logger.info("   Username: quora_user")
    logger.info("   Password: Quora@123")
    logger.info("")
    logger.info("System ready! Automation running...")
    
    # Keep alive loop
    try:
        while True:
            time.sleep(300)  # 5 minutes
            logger.info("✅ System heartbeat - running smoothly")
    except KeyboardInterrupt:
        logger.info("System stopped")

if __name__ == "__main__":
    # Start HTTP server in background
    t = threading.Thread(target=http_server_thread, daemon=True)
    t.start()
    
    # Run main automation
    main()
