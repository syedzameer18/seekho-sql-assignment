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

