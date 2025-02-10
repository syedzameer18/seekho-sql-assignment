# 🚀 Seekho SQL Assignment

## 📌 Overview
This project contains SQL queries to analyze user retention and session behavior for the **Seekho app**. The goal is to:
1. **Calculate Day 1 Retention Rate** – Identify new users and check how many return the next day.
2. **Identify User Sessions** – Group events into sessions based on a 30-minute inactivity threshold.
3. **Suggest Strategies to Improve Day-on-Day Retention** – Propose data-driven and product strategies.

---

## 📂 Table of Contents
- [Database Schema](#-database-schema)
- [Queries](#-queries)
  - [Day 1 Retention Query](#-day-1-retention-query)
  - [User Sessions Query](#-user-sessions-query)
- [How to Run](#-how-to-run)
- [Retention Strategy](#-retention-strategy)

---

## 🗄️ Database Schema

### **1️⃣ user_activity (User Login Activity)**
| Column Name   | Data Type |
|--------------|-----------|
| user_id      | INT       |
| activity_date | DATE      |

### **2️⃣ user_events (User Events Tracking)**
| Column Name   | Data Type  |
|--------------|------------|
| user_id      | INT        |
| event_type   | STRING     |
| event_time   | TIMESTAMP  |

---

## 💡 Queries

### **📊 Day 1 Retention Query**
This query calculates **Day 1 retention rate**, which is the percentage of users who return exactly one day after their first login.

```sql
WITH first_activity AS (
    SELECT user_id, MIN(activity_date) AS first_date
    FROM user_activity
    GROUP BY user_id
),
next_day_activity AS (
    SELECT DISTINCT ua.user_id, ua.activity_date
    FROM user_activity ua
    JOIN first_activity fa ON ua.user_id = fa.user_id
    WHERE ua.activity_date = DATE_ADD(fa.first_date, INTERVAL 1 DAY)
)
SELECT fa.first_date AS activity_date,
       COUNT(fa.user_id) AS new_users,
       COUNT(nda.user_id) AS returned_users,
       ROUND(COUNT(nda.user_id) / COUNT(fa.user_id), 2) AS day_1_retention_rate
FROM first_activity fa
LEFT JOIN next_day_activity nda ON fa.user_id = nda.user_id
GROUP BY fa.first_date
ORDER BY fa.first_date;
### 🕒 User Sessions Query
This query identifies user sessions, where a session is a sequence of events occurring within 30 minutes of the previous event.

sql
Copy
Edit
WITH event_data AS (
    SELECT user_id, event_time,
           LAG(event_time) OVER (PARTITION BY user_id ORDER BY event_time) AS prev_event_time
    FROM user_events
),
session_data AS (
    SELECT user_id, event_time,
           CASE 
               WHEN TIMESTAMPDIFF(MINUTE, prev_event_time, event_time) > 30 OR prev_event_time IS NULL 
               THEN 1 ELSE 0 
           END AS new_session
    FROM event_data
),
session_assignment AS (
    SELECT user_id, event_time, 
           SUM(new_session) OVER (PARTITION BY user_id ORDER BY event_time) AS session_id
    FROM session_data
)
SELECT user_id, session_id, 
       MIN(event_time) AS session_start_time, 
       MAX(event_time) AS session_end_time, 
       TIMEDIFF(MAX(event_time), MIN(event_time)) AS session_duration,
       COUNT(event_time) AS event_count
FROM session_assignment
GROUP BY user_id, session_id
ORDER BY user_id, session_id;
🛠️ How to Run
1️⃣ Setup MySQL Database
sql
Copy
Edit
CREATE DATABASE seekho_db;
USE seekho_db;
2️⃣ Create Tables
sql
Copy
Edit
CREATE TABLE user_activity (
    user_id INT NOT NULL,
    activity_date DATE NOT NULL,
    PRIMARY KEY (user_id, activity_date)
);

CREATE TABLE user_events (
    user_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_time TIMESTAMP NOT NULL,
    PRIMARY KEY (user_id, event_time)
);
3️⃣ Insert Sample Data
sql
Copy
Edit
INSERT INTO user_activity (user_id, activity_date) VALUES
(1, '2023-09-10'), (2, '2023-09-10'), (1, '2023-09-11'),
(3, '2023-09-11'), (2, '2023-09-12'), (4, '2023-09-12'),
(3, '2023-09-12'), (4, '2023-09-13');

INSERT INTO user_events (user_id, event_type, event_time) VALUES
(1, 'click', '2023-09-10 10:00:00'),
(1, 'scroll', '2023-09-10 10:10:00'),
(1, 'click', '2023-09-10 10:50:00'),
(1, 'scroll', '2023-09-10 11:40:00'),
(2, 'click', '2023-09-10 09:00:00'),
(2, 'scroll', '2023-09-10 09:20:00'),
(2, 'click', '2023-09-10 10:30:00');
4️⃣ Run Queries
After setting up the database, run the Day 1 retention and User sessions queries.

📈 Retention Strategy
To improve Day-on-Day retention, we can implement:

1️⃣ Personalized Content – Recommend content based on user interests.
2️⃣ Gamification – Use badges, streaks, and rewards for consistent engagement.
3️⃣ Push Notifications – Remind users about content they left incomplete.
4️⃣ Community Engagement – Encourage discussions, quizzes, and peer interactions.
5️⃣ A/B Testing – Test different UI/UX changes to optimize retention.

📎 Resources
MySQL Workbench
GitHub
Seekho Platform
👤 Author
Syed Zameer
🚀 Data Analyst | SQL Enthusiast

