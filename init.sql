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
