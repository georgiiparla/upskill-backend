DELETE FROM users;
DELETE FROM quests;
DELETE FROM feedback_history;
DELETE FROM leaderboard;
DELETE FROM agenda_items;
DELETE FROM activity_stream;
DELETE FROM meetings;

-- Reset the auto-increment counters for SQLite
DELETE FROM sqlite_sequence;

-- If try to log in using the following emails, you get the error since any inserted value will be converted to hash and it will be compared with placeholder_digest which is invalid hash by itself

INSERT INTO users (id, username, email, password_digest) VALUES
(1, 'Alex Rivera', 'alex@example.com', 'placeholder_digest'),
(2, 'Casey Jordan', 'casey@example.com', 'placeholder_digest'),
(3, 'Taylor Morgan', 'taylor@example.com', 'placeholder_digest'),
(4, 'Georgii Parla', 'georgii@example.com', 'placeholder_digest'),
(5, 'Jeff Bezos', 'jeff@example.com', 'placeholder_digest'),
(6, 'Joe Vella', 'joe@example.com', 'placeholder_digest');

INSERT INTO quests (title, description, points, progress, completed) VALUES
('Adaptability Ace', 'Complete the "Handling Change" module and score 90% on the quiz.', 150, 100, 1),
('Communication Pro', 'Provide constructive feedback on 5 different project documents.', 200, 60, 0),
('Leadership Leap', 'Lead a project planning session and submit the meeting notes.', 250, 0, 0),
('Teamwork Titan', 'Successfully complete a paired programming challenge.', 100, 100, 1);

INSERT INTO feedback_history (user_id, subject, content, created_at, sentiment) VALUES
(1, 'Q3 Marketing Plan', 'The plan is well-structured...', '2025-08-15', 'Neutral'),
(2, 'New Feature Design', 'I love the new UI!...', '2025-08-14', 'Positive'),
(3, 'API Documentation', 'The endpoint for user authentication is missing...', '2025-08-12', 'Negative');

INSERT INTO leaderboard (user_id, points, badges) VALUES
(1, 4250, '🚀,🎯,🔥'),
(2, 3980, '💡,🎯'),
(3, 3710, '🤝'),
(4, 1300, '🚀,🔥'),
(5, 1800, '🎯'),
(6, 2541, '🤝');

INSERT INTO agenda_items (type, title, category, due_date) VALUES
('article', 'The Art of Giving Constructive Feedback', 'Communication', '2025-08-18'),
('meeting', 'Q3 Project Kickoff', 'Planning', '2025-08-19'),
('article', 'Leading Without Authority', 'Leadership', '2025-08-20');

INSERT INTO activity_stream (user_id, action, created_at) VALUES
(5, 'completed the quest "Onboarding Champion".', '45m ago'),
(1, 'opened a feedback request for the "Q4 Product Launch" document.', '15m ago'),
(3, 'edited the "Engineering Team Weekly Agenda".', '3h ago'),
(2, 'published a new article titled "Mastering Asynchronous Communication".', '8h ago'),
(4, 'edited the "Linux Development Roadmap".', '2d ago');

INSERT INTO meetings (title, meeting_date, status) VALUES
('Q3 Project Kickoff', '2025-08-19', 'Upcoming'),
('Weekly Sync: Sprint 14', '2025-08-12', 'Complete'),
('Design Review: New Feature', '2025-08-11', 'Complete');
