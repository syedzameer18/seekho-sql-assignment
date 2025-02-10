CREATE TABLE user_activity (
    user_id INT NOT NULL,
    activity_date DATE NOT NULL,
    PRIMARY KEY (user_id, activity_date)
);
INSERT INTO user_activity (user_id, activity_date) VALUES
(1, '2023-09-10'),
(2, '2023-09-10'),
(1, '2023-09-11'),
(3, '2023-09-11'),
(2, '2023-09-12'),
(4, '2023-09-12'),
(3, '2023-09-12'),
(4, '2023-09-13');
INSERT INTO user_events (user_id, event_type, event_time) VALUES
(1, 'click', '2023-09-10 10:00:00'),
(1, 'scroll', '2023-09-10 10:10:00'),
(1, 'click', '2023-09-10 10:50:00'),
(1, 'scroll', '2023-09-10 11:40:00'),
(2, 'click', '2023-09-10 09:00:00'),
(2, 'scroll', '2023-09-10 09:20:00'),
(2, 'click', '2023-09-10 10:30:00');
SHOW TABLES;
SELECT * FROM user_activity;
SELECT * FROM user_events;

with first_activity as(
	select user_id, MIN(activity_date) as first_date
	from user_activity
	group by user_id
),
next_day_activity as(
	select distinct ua.user_id, ua.activity_date
    from user_activity ua
    join first_activity fa on ua.user_id = fa.user_id
    where ua.activity_date = date_add(fa.first_date, interval 1 day)
)
SELECT fa.first_date AS activity_date,
       COUNT(fa.user_id) AS new_users,
       COUNT(nda.user_id) AS returned_users,
       ROUND(COUNT(nda.user_id) / COUNT(fa.user_id), 2) AS day_1_retention_rate
FROM first_activity fa
LEFT JOIN next_day_activity nda ON fa.user_id = nda.user_id
GROUP BY fa.first_date
ORDER BY fa.first_date;

 -- Query to identify user sessions
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

