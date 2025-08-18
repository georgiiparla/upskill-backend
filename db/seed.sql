-- Seed data for the quests table
INSERT INTO quests (title, description, points, progress, completed) VALUES
('Adaptability Ace', 'Complete the "Handling Change" module and score 90% on the quiz.', 150, 100, 1),
('Communication Pro', 'Provide constructive feedback on 5 different project documents.', 200, 60, 0),
('Leadership Leap', 'Lead a project planning session and submit the meeting notes.', 250, 0, 0),
('Teamwork Titan', 'Successfully complete a paired programming challenge.', 100, 100, 1);

-- Seed data for the feedback_history table
INSERT INTO feedback_history (subject, content, created_at, sentiment) VALUES
('Q3 Marketing Plan', 'The plan is well-structured, but the timeline seems a bit too aggressive. Consider adding a buffer week.', '2025-08-15', 'Neutral'),
('New Feature Design', 'I love the new UI! It''s much more intuitive than the previous version. Great work!', '2025-08-14', 'Positive'),
('API Documentation', 'The endpoint for user authentication is missing examples. It was difficult to understand the required request body.', '2025-08-12', 'Negative');

-- Seed data for the leaderboard table
INSERT INTO leaderboard (name, points, badges) VALUES
('Alex Rivera', 4250, '🚀,🎯,🔥'),
('Casey Jordan', 3980, '💡,🎯'),
('Taylor Morgan', 3710, '🤝');

-- Seed data for the dashboard components
INSERT INTO agenda_items (type, title, category, due_date) VALUES
('article', 'The Art of Giving Constructive Feedback', 'Communication', '2025-08-18'),
('meeting', 'Q3 Project Kickoff', 'Planning', '2025-08-19'),
('article', 'Leading Without Authority', 'Leadership', '2025-08-20');

INSERT INTO activity_stream (user_name, action, created_at) VALUES
('Casey Jordan', 'completed the quest "Teamwork Titan".', '5m ago'),
('Alex Rivera', 'provided feedback on the "Q3 Marketing Plan".', '2h ago'),
('Taylor Morgan', 'updated the status of task "Deploy Staging Server".', '1d ago');

INSERT INTO meetings (title, meeting_date, status) VALUES
('Q3 Project Kickoff', '2025-08-19', 'Upcoming'),
('Weekly Sync: Sprint 14', '2025-08-12', 'Complete'),
('Design Review: New Feature', '2025-08-11', 'Complete');