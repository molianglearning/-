CREATE DATABASE medical_expert_subscription;

USE medical_expert_subscription;

-- 用户表
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 专家表
CREATE TABLE experts (
    expert_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    title VARCHAR(50),
    specialty VARCHAR(100),
    hospital VARCHAR(100),
    description TEXT,
    subscription_fee DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 标签表
CREATE TABLE tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 专家标签关联表
CREATE TABLE expert_tags (
    expert_id INT,
    tag_id INT,
    PRIMARY KEY (expert_id, tag_id),
    FOREIGN KEY (expert_id) REFERENCES experts(expert_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);

-- 订阅记录表
CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    expert_id INT,
    subscription_start DATE,
    subscription_end DATE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (expert_id) REFERENCES experts(expert_id)
);